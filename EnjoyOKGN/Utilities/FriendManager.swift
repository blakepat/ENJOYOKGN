//
//  FriendManager.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-25.
//

import Foundation
import CloudKit

final class FriendManager: ObservableObject {
    
    @Published var friends: [OKGNProfile] = [] {
        didSet {
            print("✅ FriendList set!")
        }
    }
    
    @Published var alertItem: AlertItem?
    
    
    func acceptFriend(_ friend: CKRecord) {

        if let userProfile = CloudKitManager.shared.profile {
            
            var friends = userProfile.convertToOKGNProfile().friends
            friends.append(CKRecord.Reference(record: friend, action: .none))
            
            userProfile[OKGNProfile.kFriends] = friends
            //To-do: erase request from request list after adding.
            userProfile[OKGNProfile.kRequests] = self.getRequestsMinusNewFollower(newFollower: CKRecord.Reference(record: friend, action: .none),
                                                                                  profile: userProfile)
            
            Task {
                do {
                    await addSelfToFriendAndRemoveRequest(friend: friend)
                    let _ = try await CloudKitManager.shared.save(record: userProfile)
                    print("✅ follower accepted!")
                } catch {
                    DispatchQueue.main.async {
                        self.alertItem = AlertContext.cannotRetrieveProfile
                        print("⚠️ alert item set")
                    }
                    print("❌ failed saving friend - accept follower")
                    print(error)
                }
            }
        }
    }
    
    func addSelfToFriendAndRemoveRequest(friend: CKRecord) async {
        guard let friendProfile = try? await CloudKitManager.shared.getFriendUserRecord(id: friend.recordID), let profileRecord = CloudKitManager.shared.profileRecordID else { return }
        let friendOKGNProfile = friend.convertToOKGNProfile()
        
        Task {
            friendProfile[OKGNProfile.kRequests] = friendOKGNProfile.requests.filter({ $0.recordID != profileRecord })
            friendOKGNProfile.friends.append(CKRecord.Reference(recordID: profileRecord, action: .none))
            
            let selfReference = CKRecord.Reference(recordID: profileRecord, action: .none)
            var friendsfriends = friendOKGNProfile.friends
            friendsfriends.append(selfReference)
            friendProfile[OKGNProfile.kFriends] = friendsfriends
            
            Task {
                do {
                    let _ = try await CloudKitManager.shared.save(record: friendProfile)
                    print("✅💜 Success CHANGING FRIEND LIST!")
                } catch {
                    print("❌Failure CHANGING FRIEND LIST!")
                    print("⚠️⚠️\(error)")
                }
            }
            
        }
        
        
        
    }
    
    
    
    func removeRequestAfterAccepting(follower: CKRecord) {
        
        if let userProfile = CloudKitManager.shared.profile {
            if userProfile.convertToOKGNProfile().followers.contains(CKRecord.Reference(recordID: follower.recordID, action: .none)) {
                userProfile[OKGNProfile.kRequests] = getRequestsMinusNewFollower(newFollower: CKRecord.Reference(record: follower, action: .none), profile: userProfile)

                Task {
                    do {
                        let _ = try await CloudKitManager.shared.save(record: userProfile)
                        print("✅ friend added!")
                    } catch {
                        print("❌ failed adding friend - Remove Request")
                        print(error)
                    }
                }
                return
            }
        }
    }
    
    func removeDeletedBeforeReAdding(follower: CKRecord) {
        
        if let userProfile = CloudKitManager.shared.profile {
            if userProfile.convertToOKGNProfile().deleteList.contains(CKRecord.Reference(recordID: follower.recordID, action: .none)) {
                userProfile[OKGNProfile.kDeleteList] = getDeletedMinusNewAdd(newAdd: CKRecord.Reference(record: follower, action: .none), profile: userProfile)

                Task {
                    do {
                        let _ = try await CloudKitManager.shared.save(record: userProfile)
                        print("✅ friend added!")
                    } catch {
                        DispatchQueue.main.async {
                            self.alertItem = AlertContext.cannotRetrieveProfile
                        }
                        print("❌ failed adding friend - removeDeleted")
                        print(error)
                    }
                }
                return
            }
        }
    }
    
    
    
    func friendMediator(for user: CKRecord) {
        
        Task {
            do {
                let friends = try await CloudKitManager.shared.getFriends(for: CKRecord.Reference.init(recordID: user.recordID, action: .none))
                
                print("✅ Success getting followers")
                var nonDeletedFriends: [CKRecord] = []
                if CloudKitManager.shared.profile!.convertToOKGNProfile().deleteList.isEmpty {
                    populateFriendsList(friendList: friends)
                } else {
                    for deletedUser in CloudKitManager.shared.profile!.convertToOKGNProfile().deleteList {
                        print("CHECKING DELETED USERS")
                        nonDeletedFriends.append(contentsOf: friends.filter { $0.recordID != deletedUser.recordID })
                    }
                    populateFriendsList(friendList: nonDeletedFriends)
                }
            } catch {
                print("❌ Error getting friends")
            }
        }
        
//        CloudKitManager.shared.getFriends(for: CKRecord.Reference.init(recordID: user.recordID, action: .none)) { [self] result in
//            switch result {
//            case .success(let friends):
//                print("✅ Success getting followers")
//                var nonDeletedFriends: [CKRecord] = []
//                if CloudKitManager.shared.profile!.convertToOKGNProfile().deleteList.isEmpty {
//                    populateFriendsList(friendList: friends)
//                } else {
//                    for deletedUser in CloudKitManager.shared.profile!.convertToOKGNProfile().deleteList {
//                        print("CHECKING DELETED USERS")
//                        nonDeletedFriends.append(contentsOf: friends.filter { $0.recordID != deletedUser.recordID })
//                    }
//                    populateFriendsList(friendList: nonDeletedFriends)
//                }
//
//            case .failure(_):
//                print("❌ Error getting friends")
//            }
//        }
    }
    

    func populateFriendsList(friendList: [CKRecord]) {
        
        DispatchQueue.main.async {
            self.friends = []
        }
        for friend in friendList {
            self.removeRequestAfterAccepting(follower: friend)
            
            Task {
                do {
                    let newFriend = try await CloudKitManager.shared.fetchRecord(with: friend.recordID)
                    DispatchQueue.main.async {
                        self.friends.append(OKGNProfile(record: newFriend))
                    }
                } catch {
                    print("❌🤢 error retreving friend")
                }
            }
        }
    }
    
    func getRequestsMinusNewFollower(newFollower: CKRecord.Reference, profile: CKRecord) -> [CKRecord.Reference] {
        
        var requests: [CKRecord.Reference] = []
        
        for request in profile.convertToOKGNProfile().requests where request.recordID != newFollower.recordID {
            requests.append(request)
        }
        
        return requests
    }
    
    
    func getDeletedMinusNewAdd(newAdd: CKRecord.Reference, profile: CKRecord) -> [CKRecord.Reference] {
        
        var requests: [CKRecord.Reference] = []
        
        for request in profile.convertToOKGNProfile().deleteList where request.recordID != newAdd.recordID {
            requests.append(request)
        }
        
        return requests
    }
    
    
    func compareRequestsAndFriends() {
        
        guard let userProfile = CloudKitManager.shared.profile else {
            return
        }
        
        for friend in userProfile.convertToOKGNProfile().followers {
            if userProfile.convertToOKGNProfile().requests.contains(friend) {
                userProfile[OKGNProfile.kRequests] = getRequestsMinusNewFollower(newFollower: friend, profile: userProfile)
                
                Task {
                    do {
                        let _ = try await CloudKitManager.shared.save(record: userProfile)
                        print("✅ friend added!")
                    } catch {
                        print("❌ failed adding friend")
                        print(error)
                    }
                }
            }
        }
    }
    
    func deleteFriends(index: IndexSet) {
        if let profile = CloudKitManager.shared.profile {
            
            let friendToDelete = CKRecord.Reference(recordID: friends[index[index.startIndex]].id, action: .none)
            
            let friendsWithout = profile.convertToOKGNProfile().friends.filter({ $0.recordID != friendToDelete.recordID })
            
            profile[OKGNProfile.kFriends] = friendsWithout
            friends.remove(atOffsets: index)
            
            Task {
                do {
                    await deleteSelfFromFriend(friend: friendToDelete.recordID)
                    let _ = try await CloudKitManager.shared.save(record: profile)
                    print("✅💜 Success adding friend to delete list!")
                } catch {
                    print("❌💜Failure adding friend to delete list")
                    print(error)
                }
            }
        }
    }
    
    func deleteSelfFromFriend(friend: CKRecord.ID) async {
        guard let friendsProfile = try? await CloudKitManager.shared.getFriendUserRecord(id: friend) else { return }
        let friendsfriendsWithout = friendsProfile.convertToOKGNProfile().friends.filter({ $0.recordID != CloudKitManager.shared.profileRecordID })
        
        friendsProfile[OKGNProfile.kFriends] = friendsfriendsWithout
        
        Task {
            do {
                let _ = try await CloudKitManager.shared.save(record: friendsProfile)
                print("✅💜 Success deleting self from friends friend list!")
            } catch {
                print("❌💜Failure deleting self from friends friend list")
                print(error)
            }
        }
    }
    
    
//    func removeFriendAfterDeletion() async {
//        if let profile = CloudKitManager.shared.profile {
//
//            Task {
//                do {
//                    let usersToRemove = try await CloudKitManager.shared.getUsersToRemove(for: CKRecord.Reference(recordID: profile.recordID, action: .none))
//                    let followers = profile.convertToOKGNProfile().followers
//                    print("USERS TO REMOVE LIST: \(usersToRemove)")
//
//
//                    let newFollowers = followers.filter({ !usersToRemove.contains(CKRecord(recordType: "OKGNProfile", recordID: $0.recordID)) })
//                    print("NEW FOLLOWERS LIST: \(newFollowers)")
//
//                    profile[OKGNProfile.kFollowers] = newFollowers
//
//                    Task {
//                        do {
//                            await removeItemsFromDeleteList(forFriendID: usersToRemove[0].recordID)
//                            let _ = try await CloudKitManager.shared.save(record: profile)
//                            print("✅💜 Success Removing friend!")
//                        } catch {
//                            print("❌💜Failure removing friend")
//                            print("⚠️⚠️\(error)")
//                        }
//                    }
//
//                } catch let err {
//                    print("⚠️\(err)")
//                }
//            }
//        }
//    }
    
    
//    func removeItemsFromDeleteList(forFriendID: CKRecord.ID) async {
//        guard let profile = try? await CloudKitManager.shared.getFriendUserRecord(id: forFriendID) else { return }
//        Task {
//            profile[OKGNProfile.kDeleteList] = nil
//            
//            Task {
//                do {
//                    let _ = try await CloudKitManager.shared.save(record: profile)
//                    print("✅💜 Success CHANGING DELETE LIST!")
//                } catch {
//                    print("❌Failure CHANGING DELETE LIST!")
//                    print("⚠️⚠️\(error)")
//                }
//            }
//            
//        }
//    }
    
}
