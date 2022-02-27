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
    
    func showFriendSearchView() {
        let alert = UIAlertController(title: "Add Friend", message: "Add friend via their display name", preferredStyle: .alert)
        alert.addTextField { (nameForm) in
            nameForm.placeholder = "friend's name..."
            nameForm.autocorrectionType = .no
        }
        
        let save = UIAlertAction(title: "Add", style: .default) { save in
            
            guard let userProfile = CloudKitManager.shared.profile else {
                //TO-DO: create alert for unable to get profile
                return
            }
            

            if alert.textFields![0].text?.count ?? 0 > 0 && alert.textFields![0].text?.count ?? 21 < 21 {
                // Call function to add friend here
                self.friendManager.addFriend(friendName: alert.textFields![0].text ?? "") { result in
                    switch result {
                    case .success(let friend):
                        print("✅🥶 \(friend.convertToOKGNProfile().name) - friend retreived")
                
                        userProfile[OKGNProfile.kFriends] = [CKRecord.Reference(record: friend, action: .none)]
                        CloudKitManager.shared.save(record: userProfile) { result in
                            switch result {
                            case .success(_):
                                print("✅✅ friend added!")
                            case .failure(let error):
                                print("❌❌ failed adding friend")
                                print(error)
                            }
                        }
                    case .failure(_):
                        print("❌ Error fetching friend")
                    }
                }
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
}
