//
//  AddFriendModalView.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-09-23.
//

import SwiftUI
import CloudKit

struct AddFriendModalView: View {
    
    @ObservedObject var friendManager = FriendManager()
    
    @State var users = [OKGNProfile]()
    @State var cursor: CKQueryOperation.Cursor?
    @State var requests: [CKRecord.Reference]?
    @State private var searchText = ""
    @State private var alertItem: AlertItem?
    
    var searchResults: [OKGNProfile] {

       if searchText.isEmpty {
           return users
       } else {
           return users.filter({ $0.name.contains(searchText)
           })
       }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(0..<searchResults.count, id: \.self) { index in
                        
                        let user = searchResults[index]
                        let alreadyRequested = requests?.contains(CKRecord.Reference(recordID: user.id, action: .none)) ?? false
                        
                        HStack {
                            Image(uiImage: user.avatar.convertToUIImage(in: .square))
                                .resizable()
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                            
                            Text(user.name)
                            
                            Spacer()
                            
                            Button {
                                if alreadyRequested {
                                    cancelRequest(request: user.id)
                                } else {
                                    addFriend(friendRecord: CKRecord(recordType: "OKGNProfile", recordID: user.id))
                                    requests?.append(CKRecord.Reference(recordID: user.id, action: .none))
                                }
                            } label: {
                                Text(alreadyRequested ? "Cancel" : "Add Friend")
                                    .contentShape(Rectangle())
                                    .padding(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(.blue)
                                    )
                                    .background(alreadyRequested ? Color.white : Color.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .font(.caption)
                                    .foregroundColor(alreadyRequested ? .blue : .white)
                                
                                    
                            }
                        }
                        .onAppear {
                            if index == 10 {
                                Task {
                                    do {
                                        guard let profile = CloudKitManager.shared.profile else { return }
                                        
                                        (users, cursor)  = try await CloudKitManager.shared.getUsers(for: profile, passedCursor: cursor)
                                    } catch let err {
                                        print("🤢 \(err)")
                                    }
                                }
                            }
                        }
                    }
                }.searchable(text: $searchText)
            }
            .alert(item: $alertItem, content: { alertItem in
                Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
            })
            .navigationBarTitle("Add a new friend")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task {
                    do {
                        guard let profile = CloudKitManager.shared.profile else { return }
                        
                        requests = profile.convertToOKGNProfile().requests
                        
                        (users, cursor)  = try await CloudKitManager.shared.getUsers(for: profile, passedCursor: nil)
                    } catch let err {
                        print("🤢 \(err)")
                    }
                    
                }
        }
        }
    }
    
    

    
    
    func addFriend(friendRecord: CKRecord) {
        Task {
            do {
                
                guard let friendProfile = try? await CloudKitManager.shared.getFriendUserRecord(id: friendRecord.recordID, completed: {}), let profileRecord = CloudKitManager.shared.profileRecordID else { return }
                let friendOKGNProfile = friendProfile.convertToOKGNProfile()

                var friendsExistingRequests = friendOKGNProfile.requests
                friendsExistingRequests.append(CKRecord.Reference(recordID: profileRecord, action: .none))
                
                friendProfile[OKGNProfile.kRequests] = friendsExistingRequests
                
                do {
                    let _ = try await CloudKitManager.shared.save(record: friendProfile)
                    print("✅✅ friend added!")
                } catch {
                    cancelRequest(request: friendRecord.recordID)
                    alertItem = AlertContext.cannotRetrieveProfile
                    print("❌❌ failed adding friend")
                    print(error)
                }
            }
        }
    }
    

    func cancelRequest(request: CKRecord.ID) {
        Task {
            do {
                guard let friendProfile = try? await CloudKitManager.shared.getFriendUserRecord(id: request, completed: {}), let profileRecord = CloudKitManager.shared.profileRecordID else { return }
                let friendOKGNProfile = friendProfile.convertToOKGNProfile()
                
                let friendsRequestsWithoutCancelled = friendOKGNProfile.requests.filter({ $0.recordID != profileRecord })
                friendProfile[OKGNProfile.kRequests] = friendsRequestsWithoutCancelled
                self.requests = self.requests?.filter({ $0.recordID != request })
                
                do {
                    let _ = try await CloudKitManager.shared.save(record: friendProfile)
                    print("✅✅ friend added!")
                } catch {
                    
                    print("❌❌ failed adding friend")
                    print(error)
                }
            }
        }
    }
}

struct AddFriendModalView_Previews: PreviewProvider {
    static var previews: some View {
        AddFriendModalView()
    }
}
