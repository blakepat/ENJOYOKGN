//
//  ReviewManager.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-16.
//

import SwiftUI
import CloudKit


final class ReviewManager: ObservableObject {
    
    @Published var userReviews: [OKGNReview] = []
    @Published var allFriendsReviews: [OKGNReview] = []
    @Published var friendReviews: [OKGNReview] = []
    var cursor: CKQueryOperation.Cursor? = nil
    
    func getUserReviews() {
        guard let profileID = CloudKitManager.shared.profileRecordID else {
            print("❌ could not get profileID")
            return
        }

        Task {
            do {
                let receivedReviews = try await CloudKitManager.shared.getUserReviews(for: profileID)
                
                DispatchQueue.main.async {
                    print("✅ REVIEWS SET")
                    
                    self.userReviews = []
//                    self.userReviews = receivedReviews


                    for category in categories {
                        var sortedReviews: [OKGNReview] = receivedReviews.filter({returnCategoryFromString($0.locationCategory) == category})
                        for i in 0..<min(sortedReviews.count, 3) {
                            sortedReviews[i].ranking = rankings[i]
                        }
                        self.userReviews.append(contentsOf: sortedReviews)
                    }
                }
            } catch let err {
                print(err)
                print("❌ Error fetching reviews!")
            }
        }
    }
    

    
    func getOneFriendReviews(id: CKRecord.ID) {
        Task {
            do {
                let receivedReviews = try await CloudKitManager.shared.getUserReviews(for: id)
                
                DispatchQueue.main.async {
                    print("✅ ONE FRIEND REVIEWS SET")
                    
                    self.friendReviews = []
//                    self.friendReviews = receivedReviews
                    
                    for category in categories {
                        var sortedReviews: [OKGNReview] = receivedReviews.filter({returnCategoryFromString($0.locationCategory) == category})
                        for i in 0..<min(sortedReviews.count, 3) {
                            sortedReviews[i].ranking = rankings[i]
                        }
                        self.friendReviews.append(contentsOf: sortedReviews)
                    }
                }
            } catch {
                print("❌ Error fetching reviews!")
            }
        }
    }
    
    
    func getAllFriendsReviews(location: String? = nil) {
        guard let profile = CloudKitManager.shared.profile else {
            print("❌ could not get profileID")
            return
        }
        
        Task {
            
            do {
                let friends = try await CloudKitManager.shared.getFriends(for: CKRecord.Reference(recordID: profile.recordID, action: .none))
                
                DispatchQueue.main.async {
                    if friends == [] { self.allFriendsReviews = [] }
                }
                
                
                var receivedReviews: [OKGNReview] = []

                
                if location != nil {
                    (receivedReviews, self.cursor) = try await CloudKitManager.shared.getOneLocationFriendsReviews(for: friends.map { CKRecord.Reference(recordID: $0.recordID, action: .none) }, location: location!, passedCursor: cursor) 
                } else {
                    if cursor == nil && !self.allFriendsReviews.isEmpty { return }
                    (receivedReviews, self.cursor) = try await CloudKitManager.shared.getFriendsReviews(for: friends.map { CKRecord.Reference(recordID: $0.recordID, action: .none) }, passedCursor: self.cursor)
                }
                
                if self.cursor == nil && self.allFriendsReviews.isEmpty {
                    let firstBatchFriendsReviewsReceived = receivedReviews
                    DispatchQueue.main.async {
                        self.allFriendsReviews = firstBatchFriendsReviewsReceived
                    }
                } else if self.cursor == nil {
                    let allFriendsReviewsReceived = receivedReviews
                    DispatchQueue.main.async {
                        self.allFriendsReviews.append(contentsOf: allFriendsReviewsReceived)
                    }
                } else {
                    let notAllFriendsReviews = receivedReviews
                    DispatchQueue.main.async {
                        self.allFriendsReviews.append(contentsOf: notAllFriendsReviews)
                    }
                }
                
//                let rankedReviews = self.getRankingForFriendsReviews(reviews: receivedReviews, friends: friends.map { $0.convertToOKGNProfile() })
                
//                DispatchQueue.main.async {
//                    print("✅ FRIENDS REVIEWS SET")
////                    self.allFriendsReviews = []
//                    self.allFriendsReviews.append(contentsOf: receivedReviews)
//                }
//                CloudKitManager.shared.getFriendsReviews(for: friends.map { CKRecord.Reference(recordID: $0.recordID, action: .none) }) { result in
//                    switch result {
//                    case .success(let receivedReviews):
//                        DispatchQueue.main.async {
//                            print("✅ FRIENDS REVIEWS SET")
//
//                            self.friendsReviews = []
//                            self.friendsReviews.append(contentsOf: receivedReviews.sorted { $0.date > $1.date } )
//                        }
//
//                    case .failure(_):
//                        print("❌ Error fetching reviews!")
//                    }
//                }
            } catch {
                print("❌ Error getting friends for reviews")
            }
        }
        
//        CloudKitManager.shared.getFriends(for: CKRecord.Reference(recordID: profile.recordID, action: .none)) { result in
//            switch result {
//                
//            case .success(let friends):
//                
//                if friends == [] { self.friendsReviews = [] }
//                
//                CloudKitManager.shared.getFriendsReviews(for: friends.map { CKRecord.Reference(recordID: $0.recordID, action: .none) }) { result in
//                    switch result {
//                    case .success(let receivedReviews):
//                        DispatchQueue.main.async {
//                            print("✅ FRIENDS REVIEWS SET")
//                            
//                            self.friendsReviews = []
//                            self.friendsReviews.append(contentsOf: receivedReviews.sorted { $0.date > $1.date } )
//                        }
//
//                    case .failure(_):
//                        print("❌ Error fetching reviews!")
//                    }
//                }
//            case .failure(_):
//                print("❌ Error getting friends for reviews")
//            }
//        }
        

    }
    

    
    
    
    func getRankingForFriendsReviews(reviews: [OKGNReview], friends: [OKGNProfile]) -> [OKGNReview] {

        var rankedFriendReviews: [OKGNReview] = []

        for friend in friends {
            for category in categories {

                var sortedReviews: [OKGNReview] = reviews.filter({ returnCategoryFromString($0.locationCategory) == category && $0.reviewerName == friend.name }).sorted { $0.rating > $1.rating }
                for i in 0..<min(sortedReviews.count, 3) {
                    sortedReviews[i].ranking = rankings[i]
                }

                rankedFriendReviews.append(contentsOf: sortedReviews)

            }
        }

        return rankedFriendReviews.sorted(by: { $0.date > $1.date })
    }
}
