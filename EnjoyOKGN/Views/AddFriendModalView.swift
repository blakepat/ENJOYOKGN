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
    
    var body: some View {
        ZStack {
            List {
                ForEach(0..<users.count, id: \.self) { index in
                    
                    let user = users[index]
                    
                    HStack {
                        Image(uiImage: user.avatar.convertToUIImage(in: .square))
                            .resizable()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                        
                        Text(user.name)
                        
                        Spacer()
                        
                        Button {
                            
                            addFriend(record: CKRecord(recordType: "OKGNProfile", recordID: user.id))
                            
                        } label: {
                            Text("Add Friend")
                                .contentShape(Rectangle())
                                .padding(8)
                                .background(Color.blue.clipShape(RoundedRectangle(cornerRadius: 8)))
                                .font(.caption)
                                .foregroundColor(.white)
                            
                                
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
    
    
    
}

struct AddFriendModalView_Previews: PreviewProvider {
    static var previews: some View {
        AddFriendModalView()
    }
}
