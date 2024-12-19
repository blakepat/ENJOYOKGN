import SwiftUI
import CloudKit


struct AddFriendModalView: View {
    // MARK: - Properties
    @StateObject private var friendManager = FriendManager()
    @Environment(\.dismiss) private var dismiss
    
    @State private var users = [OKGNProfile]()
    @State private var cursor: CKQueryOperation.Cursor?
    @State private var searchText = ""
    @State private var alertItem: AlertItem?
    @State private var profile: CKRecord?
    @State private var isLoading = false
    
    // MARK: - Computed Properties
    private var searchResults: [OKGNProfile] {
        guard !searchText.isEmpty else { return users }
        return users.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                Color.OKGNDarkGray.ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    userList
                }
            }
            .alert(item: $alertItem) { alertItem in
                Alert(title: alertItem.title,
                      message: alertItem.message,
                      dismissButton: alertItem.dismissButton)
            }
            .navigationTitle("Add a new friend")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search users")
            .task {
                await loadInitialData()
            }
        }
    }
    
    // MARK: - Views
    private var userList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(searchResults, id: \.id) { user in
                    UserRowView(user: user,
                           isRequested: hasRequestedFriend(user),
                           onAddFriend: { addFriend(friendRecord: CKRecord(recordType: "OKGNProfile", recordID: user.id)) },
                           onCancelRequest: { cancelRequest(request: user.id) })
                    .onAppear {
                        if user == searchResults.last {
                            Task { await loadMoreUsers() }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }
    
    // MARK: - Helper Methods
    private func hasRequestedFriend(_ user: OKGNProfile) -> Bool {
        // Check if current user's record ID exists in the potential friend's requests
        guard let currentUserRecordID = CloudKitManager.shared.profileRecordID else { return false }
        return user.requests.contains(where: { $0.recordID == currentUserRecordID })
    }
    
    private func loadInitialData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard let profile = CloudKitManager.shared.profile else {
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
    
    private func loadMoreUsers() async {
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
    
    private func addFriend(friendRecord: CKRecord) {
        Task {
            do {
                guard let friendProfile = try? await CloudKitManager.shared.getFriendUserRecord(id: friendRecord.recordID, completed: {}),
                      let profileRecord = CloudKitManager.shared.profileRecordID else {
                    alertItem = AlertContext.cannotRetrieveProfile
                    return
                }
                
                var friendOKGNProfile = friendProfile.convertToOKGNProfile()
                friendOKGNProfile.requests.append(CKRecord.Reference(recordID: profileRecord, action: .none))
                
                friendProfile[OKGNProfile.kRequests] = friendOKGNProfile.requests
                
                let _ = try await CloudKitManager.shared.save(record: friendProfile)
                
                // Update the local users array to reflect the change
                if let index = users.firstIndex(where: { $0.id == friendRecord.recordID }) {
                    var updatedUser = users[index]
                    updatedUser.requests.append(CKRecord.Reference(recordID: profileRecord, action: .none))
                    users[index] = updatedUser
                }
                
            } catch {
                alertItem = AlertContext.unableToSendFriendRequest
                print("Failed to add friend: \(error)")
            }
        }
    }
    
    private func cancelRequest(request: CKRecord.ID) {
        Task {
            do {
                guard let friendProfile = try? await CloudKitManager.shared.getFriendUserRecord(id: request, completed: {}),
                      let profileRecord = CloudKitManager.shared.profileRecordID else {
                    alertItem = AlertContext.cannotRetrieveProfile
                    return
                }
                
                var friendOKGNProfile = friendProfile.convertToOKGNProfile()
                friendOKGNProfile.requests.removeAll { $0.recordID == profileRecord }
                
                friendProfile[OKGNProfile.kRequests] = friendOKGNProfile.requests
                
                let _ = try await CloudKitManager.shared.save(record: friendProfile)
                
                // Update the local users array to reflect the change
                if let index = users.firstIndex(where: { $0.id == request }) {
                    var updatedUser = users[index]
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

// MARK: - Supporting Views
private struct UserRowView: View {
    let user: OKGNProfile
    let isRequested: Bool
    let onAddFriend: () -> Void
    let onCancelRequest: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(uiImage: user.avatar.convertToUIImage(in: .square))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            
            Text(user.name)
                .foregroundStyle(.white)
                .font(.system(size: 16, weight: .medium))
            
            Spacer()
            
            Button(action: { isRequested ? onCancelRequest() : onAddFriend() }) {
                Text(isRequested ? "Cancel" : "Add Friend")
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(isRequested ? Color.white : Color.blue)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isRequested ? Color.blue : Color.clear, lineWidth: 1)
                    )
                    .foregroundColor(isRequested ? .blue : .white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
    }
}


// MARK: - Preview
struct AddFriendModalView_Previews: PreviewProvider {
    static var previews: some View {
        AddFriendModalView()
    }
}
//import SwiftUI
//import CloudKit
//
//struct AddFriendModalView: View {
//    
//    @ObservedObject var friendManager = FriendManager()
//    
//    @State var users = [OKGNProfile]()
//    @State var cursor: CKQueryOperation.Cursor?
////    @State var requests: [[CKRecord.Reference]]?
//    @State private var searchText = ""
//    @State private var alertItem: AlertItem?
//    @State private var profile: CKRecord?
//    
//    var searchResults: [OKGNProfile] {
//
//       if searchText.isEmpty {
//           return users
//       } else {
//           return users.filter({ $0.name.contains(searchText)
//           })
//       }
//    }
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                Color.OKGNDarkGray
//                    .edgesIgnoringSafeArea(.all)
//                List {
//                    ForEach(0..<searchResults.count, id: \.self) { index in
//                        
//                        var requests: [CKRecord.Reference] = []
//                        requests = profile?.convertToOKGNProfile().requests ?? []
//                        let user = searchResults[index]
//                        let alreadyRequested = requests.contains(CKRecord.Reference(recordID: profile.id, action: .none)) ?? false
//                        
//                        HStack {
//                            Image(uiImage: user.avatar.convertToUIImage(in: .square))
//                                .resizable()
//                                .frame(width: 30, height: 30)
//                                .clipShape(Circle())
//                            
//                            Text(user.name)
//                                .foregroundStyle(.white)
//                            
//                            Spacer()
//                            
//                            Button {
//                                if alreadyRequested {
//                                    cancelRequest(request: user.id)
//                                } else {
//                                    addFriend(friendRecord: CKRecord(recordType: "OKGNProfile", recordID: user.id))
//                                    requests?.append(CKRecord.Reference(recordID: user.id, action: .none))
//                                }
//                            } label: {
//                                Text(alreadyRequested ? "Cancel" : "Add Friend")
//                                    .contentShape(Rectangle())
//                                    .padding(8)
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 8)
//                                            .stroke(.blue)
//                                    )
//                                    .background(alreadyRequested ? Color.white : Color.blue)
//                                    .clipShape(RoundedRectangle(cornerRadius: 8))
//                                    .font(.caption)
//                                    .foregroundColor(alreadyRequested ? .blue : .white)
//                            }
//                        }
//                        .onAppear {
//                            
//                            if index == 10 {
//                                Task {
//                                    do {
//                                        guard let profile = CloudKitManager.shared.profile else { return }
//                                        
//                                        (users, cursor)  = try await CloudKitManager.shared.getUsers(for: profile, passedCursor: cursor)
//                                    } catch let err {
//                                        print("🤢 \(err)")
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    .listRowSeparator(.visible, edges: .all)
//                    .listRowBackground(Color.white.opacity(0.1))
//                    .listRowSpacing(8)
//                }
//                .searchable(text: $searchText)
//            }
//            .alert(item: $alertItem, content: { alertItem in
//                Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
//            })
//            .navigationBarTitle("Add a new friend")
//            .navigationBarTitleDisplayMode(.inline)
//            .onAppear {
//                Task {
//                    do {
//                        profile = CloudKitManager.shared.profile
//                        
////                        requests = profile.convertToOKGNProfile().requests
//                        if let profile = profile {
//                            (users, cursor) = try await CloudKitManager.shared.getUsers(for: profile, passedCursor: nil)
//                        }
//                    } catch let err {
//                        print("🤢 \(err)")
//                    }
//                    
//                }
//        }
//        }
//    }
//    
//    
//
//    
//    
//    func addFriend(friendRecord: CKRecord) {
//        Task {
//            do {
//                
//                guard let friendProfile = try? await CloudKitManager.shared.getFriendUserRecord(id: friendRecord.recordID, completed: {}), let profileRecord = CloudKitManager.shared.profileRecordID else { return }
//                let friendOKGNProfile = friendProfile.convertToOKGNProfile()
//
//                var friendsExistingRequests = friendOKGNProfile.requests
//                friendsExistingRequests.append(CKRecord.Reference(recordID: profileRecord, action: .none))
//                
//                friendProfile[OKGNProfile.kRequests] = friendsExistingRequests
//                
//                do {
//                    let _ = try await CloudKitManager.shared.save(record: friendProfile)
//                    print("✅✅ friend added!")
//                } catch {
//                    cancelRequest(request: friendRecord.recordID)
//                    alertItem = AlertContext.cannotRetrieveProfile
//                    print("❌❌ failed adding friend")
//                    print(error)
//                }
//            }
//        }
//    }
//    
//
//    func cancelRequest(request: CKRecord.ID) {
//        Task {
//            do {
//                guard let friendProfile = try? await CloudKitManager.shared.getFriendUserRecord(id: request, completed: {}), let profileRecord = CloudKitManager.shared.profileRecordID else { return }
//                let friendOKGNProfile = friendProfile.convertToOKGNProfile()
//                
//                let friendsRequestsWithoutCancelled = friendOKGNProfile.requests.filter({ $0.recordID != profileRecord })
//                friendProfile[OKGNProfile.kRequests] = friendsRequestsWithoutCancelled
////                self.requests = self.requests?.filter({ $0.recordID != request })
//                
//                do {
//                    let _ = try await CloudKitManager.shared.save(record: friendProfile)
//                    print("✅✅ friend added!")
//                } catch {
//                    
//                    print("❌❌ failed adding friend")
//                    print(error)
//                }
//            }
//        }
//    }
//}
//
//struct AddFriendModalView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddFriendModalView()
//    }
//}
