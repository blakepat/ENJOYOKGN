//
//  AddFriendViewModel.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2025-03-06.
//

import SwiftUI
import CloudKit


final class AddFriendViewModel: ObservableObject {
    
    @Published var users = [OKGNProfile]()
    @Published var cursor: CKQueryOperation.Cursor?
    @Published var searchText = ""
    @Published var debouncedSearchText = ""
    @Published var alertItem: AlertItem?
    @Published var profile: CKRecord?
    @Published var isLoading = false
    

    var searchResults: [OKGNProfile] {
        guard !debouncedSearchText.isEmpty else { return users }
        return users.filter { $0.name.localizedCaseInsensitiveContains(debouncedSearchText) }
    }
    
    
    @MainActor func hasRequestedFriend(_ user: OKGNProfile) -> Bool {
        // Check if current user's record ID exists in the potential friend's requests
        guard let currentUserRecordID = CloudKitManager.shared.profileRecordID else { return false }
        return user.requests.contains(where: { $0.recordID == currentUserRecordID })
    }
    
    func loadInitialData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard let profile = await CloudKitManager.shared.profile else {
                alertItem = AlertContext.profileNotFound
                return
            }
            
            self.profile = profile
            (users, cursor) = try await CloudKitManager.shared.getUsers(for: profile, passedCursor: nil)
        } catch {
            alertItem = AlertContext.unableToLoadUsers
            print("Error loading initial data: \(error)")
        }
    }
    
    func loadMoreUsers() async {
        guard let profile = profile, let currentCursor = cursor else { return }
        
        do {
            let (newUsers, newCursor) = try await CloudKitManager.shared.getUsers(for: profile, passedCursor: currentCursor)
            users.append(contentsOf: newUsers)
            cursor = newCursor
        } catch {
            alertItem = AlertContext.unableToLoadMoreUsers
            print("Error loading more users: \(error)")
        }
    }
    
    func addFriend(friendRecord: CKRecord) {
        Task {
            do {
                guard let friendProfile = try? await CloudKitManager.shared.getFriendUserRecord(id: friendRecord.recordID, completed: {}),
                      let profileRecord = await CloudKitManager.shared.profileRecordID else {
                    alertItem = AlertContext.cannotRetrieveProfile
                    return
                }
                
                let friendOKGNProfile = friendProfile.convertToOKGNProfile()
                friendOKGNProfile.requests.append(CKRecord.Reference(recordID: profileRecord, action: .none))
                
                friendProfile[OKGNProfile.kRequests] = friendOKGNProfile.requests
                
                let _ = try await CloudKitManager.shared.save(record: friendProfile)
                
                // Update the local users array to reflect the change
                if let index = users.firstIndex(where: { $0.id == friendRecord.recordID }) {
                    let updatedUser = users[index]
                    updatedUser.requests.append(CKRecord.Reference(recordID: profileRecord, action: .none))
                    users[index] = updatedUser
                }
                
            } catch {
                alertItem = AlertContext.unableToSendFriendRequest
                print("Failed to add friend: \(error)")
            }
        }
    }
    
    func cancelRequest(request: CKRecord.ID) {
        Task {
            do {
                guard let friendProfile = try? await CloudKitManager.shared.getFriendUserRecord(id: request, completed: {}),
                      let profileRecord = await CloudKitManager.shared.profileRecordID else {
                    alertItem = AlertContext.cannotRetrieveProfile
                    return
                }
                
                let friendOKGNProfile = friendProfile.convertToOKGNProfile()
                friendOKGNProfile.requests.removeAll { $0.recordID == profileRecord }
                
                friendProfile[OKGNProfile.kRequests] = friendOKGNProfile.requests
                
                let _ = try await CloudKitManager.shared.save(record: friendProfile)
                
                // Update the local users array to reflect the change
                if let index = users.firstIndex(where: { $0.id == request }) {
                    let updatedUser = users[index]
                    updatedUser.requests.removeAll { $0.recordID == profileRecord }
                    users[index] = updatedUser
                }
                
            } catch {
                alertItem = AlertContext.unableToCancelRequest
                print("Failed to cancel request: \(error)")
            }
        }
    }
}
