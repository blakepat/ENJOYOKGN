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
    
    
    func acceptFollower(_ friend: CKRecord) {
        CloudKitManager.shared.getFriendRecord(friendName: friend.convertToOKGNProfile().name) { result in
            switch result {
            case .success(_):
                if let userProfile = CloudKitManager.shared.profile {
                    userProfile[OKGNProfile.kFollowers] = [CKRecord.Reference(record: friend, action: .none)]
                    //To-do: erase request from request list after adding.
                    userProfile[OKGNProfile.kRequests] = self.getRequestsMinusNewFollower(newFollower: CKRecord.Reference(record: friend, action: .none),
                                                                                          profile: userProfile)
                    
                    CloudKitManager.shared.save(record: userProfile) { result in
                        switch result {
                        case .success(_):
                            print("✅ follower accepted!")
                            
                        case .failure(let error):
                            print("❌ failed adding friend")
                            print(error)
                        }
                    }
                }
            case .failure(_):
                print("")
            }
        }
    }
    
    
    func removeRequestAfterAccepting(follower: CKRecord) {
        
        if let userProfile = CloudKitManager.shared.profile {
            if userProfile.convertToOKGNProfile().followers.contains(CKRecord.Reference(recordID: follower.recordID, action: .none)) {
                userProfile[OKGNProfile.kRequests] = getRequestsMinusNewFollower(newFollower: CKRecord.Reference(record: follower, action: .none), profile: userProfile)

                CloudKitManager.shared.save(record: userProfile) { result in
                    switch result {
                    case .success(_):
                        print("✅ friend added!")

                    case .failure(let error):
                        print("❌ failed adding friend")
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

                CloudKitManager.shared.save(record: userProfile) { result in
                    switch result {
                    case .success(_):
                        print("✅ friend added!")

                    case .failure(let error):
                        print("❌ failed adding friend")
                        print(error)
                    }
                }
                return
            }
        }
    }
    
    
    
    func friendMediator(for user: CKRecord) {
        CloudKitManager.shared.getFriends(for: CKRecord.Reference.init(recordID: user.recordID, action: .none)) { [self] result in
            switch result {
            case .success(let friends):
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
                
            case .failure(_):
                print("❌ Error getting friends")
            }
        }
    }
    

    func populateFriendsList(friendList: [CKRecord]) {
        
        DispatchQueue.main.async {
            self.friends = []
        }
        for friend in friendList {
            self.removeRequestAfterAccepting(follower: friend)
            CloudKitManager.shared.fetchRecord(with: friend.recordID) { result in
                switch result {
                case .success(let newFriend):
                    DispatchQueue.main.async {
                        self.friends.append(OKGNProfile(record: newFriend))
                    }
                case .failure(_):
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
        
        for friend in userProfile.convertToOKGNProfile().friends {
            if userProfile.convertToOKGNProfile().requests.contains(friend) {
                userProfile[OKGNProfile.kRequests] = getRequestsMinusNewFollower(newFollower: friend, profile: userProfile)
                CloudKitManager.shared.save(record: userProfile) { result in
                    switch result {
                    case .success(_):
                        print("✅ friend added!")
                    case .failure(let error):
                        print("❌ failed adding friend")
                        print(error)
                    }
                }
            }
        }
    }
    
    func deleteFriends(index: IndexSet) {
        if let profile = CloudKitManager.shared.profile {
            profile[OKGNProfile.kDeleteList] = [CKRecord.Reference(recordID: friends[index[index.startIndex]].id, action: .none)]
            friends.remove(atOffsets: index)
            CloudKitManager.shared.save(record: profile) { result in
                switch result {
                case .success(_):
                    print("✅💜 Success Removing friend!")
                case .failure(let error):
                    print("❌💜Failure removing friend")
                    print(error)
                }
            }
        }
    }
    
    
}
