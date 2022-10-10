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
        
    @Published var detailedReviewToShow: OKGNReview?
    @Published var isShowingDetailedModalView = false
    @Published var isShowingAddFriendAlert = false
    @Published var isShowingFriendRequestAlert = false
    @Published var isShowingFriendHomePage = false
    
    @Published var reviewsSortedByRating = false
    @Published var isShowingFriendsList = false
    
    @Published var twoButtonAlertItem: TwoButtonAlertItem?
    @Published var friendReviews: [OKGNReview]?
    @Published var friend: OKGNProfile?
    
    @Published var alertItem: AlertItem?

    
    func displayFollowRequests() {

        Task {
            do {
                let friendRequests = CloudKitManager.shared.profile?.convertToOKGNProfile().requests ?? []
                
                print("✅ Success getting follow requests")
                DispatchQueue.main.async { [self] in
                    for request in friendRequests {
                        
                        guard let friends = CloudKitManager.shared.profile?.convertToOKGNProfile().followers else { return }
                        
                        if !friends.contains(CKRecord.Reference(recordID: request.recordID, action: .none)) {
                            twoButtonAlertItem = TwoButtonAlertItem(title: Text("Follow Request!"),
                                                                    message: Text(" has requested to follow you!"),
                                                                    acceptButton: .default(Text("Accept"), action: { [self] in
                                friendManager.removeRequestAfterAccepting(follower: request)
                                friendManager.acceptFriend(request)
                            }),
                                                                    dismissButton: .cancel(Text("Decline"), action: {
                                print("🥶 Friend Request Declined")
                                Task {
                                    await self.declineRequest(request: request.recordID)
                                }
                                
                                
                            }))
                        } else {
                            print("request is already a follower")
                        }
                    }
                }
            }
        }
    }
    
    
    func declineRequest(request: CKRecord.ID) async {
        
        guard let friendProfile = try? await CloudKitManager.shared.getFriendUserRecord(id: request) else { return }
        
        Task {
            do {
                let friendsRequestsWithout = friendProfile.convertToOKGNProfile().requests.filter({ $0.recordID != CloudKitManager.shared.profileRecordID })
                friendProfile[OKGNProfile.kRequests] = friendsRequestsWithout
            
                do {
                    let _ = try await CloudKitManager.shared.save(record: friendProfile)
                    print("✅✅ request decline and removed!")
                } catch {
                    
                    print("❌❌ failed request decline and removed")
                    print(error)
                }
            }
        }
    }
}
