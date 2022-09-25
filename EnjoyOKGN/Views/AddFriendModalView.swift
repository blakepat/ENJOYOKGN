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
    
    var body: some View {
        ZStack {
            List {
                ForEach(0..<users.count, id: \.self) { index in
                    
                    let user = users[index]
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
                                addFriend(record: CKRecord(recordType: "OKGNProfile", recordID: user.id))
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
            }
        }
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
    
    
    
    func addFriend(record: CKRecord) {
        
        guard let userProfile = CloudKitManager.shared.profile else {
            //TO-DO: create alert for unable to get profile
            return
        }
        
        Task {
            do {
                userProfile.convertToOKGNProfile().requests.append(CKRecord.Reference(recordID: record.recordID, action: .none))
                userProfile[OKGNProfile.kRequests] = [CKRecord.Reference(record: record, action: .none)]
                self.friendManager.removeDeletedBeforeReAdding(follower: record)
                
                do {
                    let _ = try await CloudKitManager.shared.save(record: userProfile)
                    print("✅✅ friend added!")
                } catch {
                    
                    print("❌❌ failed adding friend")
                    print(error)
                }
            }
        }
    }
    

    func cancelRequest(request: CKRecord.ID) {
        guard let userProfile = CloudKitManager.shared.profile else { return }

        Task {
            do {
                let requestsWithoutCancelled = userProfile.convertToOKGNProfile().requests.filter({ $0.recordID != request })
                userProfile[OKGNProfile.kRequests] = requestsWithoutCancelled
                self.requests = requestsWithoutCancelled
                do {
                    let _ = try await CloudKitManager.shared.save(record: userProfile)
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
