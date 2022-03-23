//
//  FriendReviewFeedModel.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-25.
//

import SwiftUI
import CloudKit


final class FriendReviewFeedModel: ObservableObject {
    
    @ObservedObject var friendManager = FriendManager()
    
    @Published var isShowingFriendsList = false
        
    @Published var detailedReviewToShow: OKGNReview?
    @Published var isShowingDetailedModalView = false
    @Published var isShowingAddFriendAlert = false
    @Published var isShowingFriendRequestAlert = false
    
    @Published var twoButtonAlertItem: TwoButtonAlertItem?
    @Published var friendReviews: [OKGNReview]?
    
    
    func showFriendSearchView() {
        let alert = UIAlertController(title: "Add Friend", message: "Follow a friend via their display name", preferredStyle: .alert)
        alert.addTextField { (nameForm) in
            nameForm.placeholder = "friend's username..."
            nameForm.autocorrectionType = .no
        }
        
        let save = UIAlertAction(title: "Add", style: .default) { save in
            
            guard let userProfile = CloudKitManager.shared.profile else {
                //TO-DO: create alert for unable to get profile
                return
            }
            

            if alert.textFields![0].text?.count ?? 0 > 0 && alert.textFields![0].text?.count ?? 21 < 21 {
                // Call function to add friend here
                
                Task {
                    do {
                        let friend = try await CloudKitManager.shared.getFriendRecord(friendName: alert.textFields![0].text ?? "")
                        
                        print("✅🥶 \(friend.convertToOKGNProfile().name) - friend retreived")
                
                        userProfile[OKGNProfile.kRequests] = [CKRecord.Reference(record: friend, action: .none)]
                        self.friendManager.removeDeletedBeforeReAdding(follower: friend)
                        
                        do {
                            let _ = try await CloudKitManager.shared.save(record: userProfile)
                            print("✅✅ friend added!")
                        } catch {
                            print("❌❌ failed adding friend")
                            print(error)
                        }
                    } catch {
                        print("❌ Error fetching friend")
                    }
                }
                
//                CloudKitManager.shared.getFriendRecord(friendName: alert.textFields![0].text ?? "") { result in
//                    switch result {
//                    case .success(let friend):
//                        print("✅🥶 \(friend.convertToOKGNProfile().name) - friend retreived")
//
//                        userProfile[OKGNProfile.kRequests] = [CKRecord.Reference(record: friend, action: .none)]
//                        self.friendManager.removeDeletedBeforeReAdding(follower: friend)
//                        CloudKitManager.shared.save(record: userProfile) { result in
//                            switch result {
//                            case .success(_):
//                                print("✅✅ friend added!")
//                            case .failure(let error):
//                                print("❌❌ failed adding friend")
//                                print(error)
//                            }
//                        }
//                    case .failure(_):
//                        print("❌ Error fetching friend")
//                    }
//                }
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.isShowingAddFriendAlert = false
        }
        
        alert.addAction(save)
        alert.addAction(cancel)
        
        let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first
        
        keyWindow?.rootViewController?.present(alert, animated: true) {
            
        }
    }
    
    
    func refreshFriendList() {
        
    }
    
    func displayFollowRequests() {
        if let profileRecordID = CloudKitManager.shared.profileRecordID {
            Task {
                do {
                    let followRequests = try await CloudKitManager.shared.getFollowRequests(for: CKRecord.Reference(recordID: profileRecordID, action: .none))
                    
                    print("✅ Success getting follow requests")
                    DispatchQueue.main.async { [self] in
                        for follower in followRequests {
                            
                        
                            twoButtonAlertItem = TwoButtonAlertItem(title: Text("Follow Request!"),
                                                                              message: Text("\(follower.convertToOKGNProfile().name) has requested to follow you!"),
                                                                    acceptButton: .default(Text("Accept"), action: { [self] in
                                friendManager.removeRequestAfterAccepting(follower: follower)
                                friendManager.acceptFollower(follower)
                            }),
                                                                              dismissButton: .cancel(Text("Decline"), action: {
                                //🥶 TO-DO: Decline friend request
                                print("🥶 Friend Request Declined")

                            }))
                        }
                    }
                } catch {
                    print("❌ Error creating friend requests")
                }
            }
            
//            CloudKitManager.shared.getFollowRequests(for: CKRecord.Reference(recordID: profileRecordID, action: .none)) { result in
//                switch result {
//                case .success(let followRequests):
//                    print("✅ Success getting follow requests")
//                    DispatchQueue.main.async { [self] in
//                        for follower in followRequests {
//
//
//                            twoButtonAlertItem = TwoButtonAlertItem(title: Text("Follow Request!"),
//                                                                              message: Text("\(follower.convertToOKGNProfile().name) has requested to follow you!"),
//                                                                    acceptButton: .default(Text("Accept"), action: { [self] in
//                                friendManager.removeRequestAfterAccepting(follower: follower)
//                                friendManager.acceptFollower(follower)
//                            }),
//                                                                              dismissButton: .cancel(Text("Decline"), action: {
//                                //🥶 TO-DO: Decline friend request
//                                print("🥶 Friend Request Declined")
//
//                            }))
//                        }
//                    }
//
//                case .failure(_):
//                    print("❌ Error creating friend requests")
//                }
//            }
        }
    }
}
