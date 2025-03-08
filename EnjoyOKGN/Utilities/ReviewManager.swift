//
//  ReviewManager.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-16.
//

import SwiftUI
import CloudKit

@MainActor
final class ReviewManager: ObservableObject {
    
    @Published var userReviews: [OKGNReview] = []
    @Published var allFriendsReviews: [OKGNReview] = []
    @Published var friendReviews: [OKGNReview] = []
    @Published var eachCategoryVisitCount = [0,0,0,0,0]
    var cursor: CKQueryOperation.Cursor? = nil
    
    
    
    func getUserReviews() {
        guard let profileID = CloudKitManager.shared.profileRecordID else {
            return
        }
        
        Task {
            do {
                let receivedReviews = try await CloudKitManager.shared.getUserReviews(for: profileID)
                
                DispatchQueue.main.async {
                    
                    self.userReviews = []
                    
                    for category in categories {
                        // Filter by category and sort by rating
                        var sortedReviews: [OKGNReview] = receivedReviews
                            .filter { returnCategoryFromString($0.locationCategory) == category }
                            .sorted { first, second in
                                let firstRating = Double(first.rating) ?? 0.0
                                let secondRating = Double(second.rating) ?? 0.0
                                return firstRating > secondRating
                            }
                        
                        for i in 0..<min(sortedReviews.count, 3) {
                            switch i {
                            case 0: sortedReviews[i].ranking = .first
                            case 1: sortedReviews[i].ranking = .second
                            case 2: sortedReviews[i].ranking = .third
                            default: sortedReviews[i].ranking = nil
                            }
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
                    
                    self.friendReviews = []
                    
                    for category in categories {
                        var sortedReviews: [OKGNReview] = receivedReviews
                            .filter { returnCategoryFromString($0.locationCategory) == category }
                            .sorted { first, second in
                                let firstRating = Double(first.rating) ?? 0.0
                                let secondRating = Double(second.rating) ?? 0.0
                                return firstRating > secondRating
                            }
                        
                        for i in 0..<min(sortedReviews.count, 3) {
                            switch i {
                            case 0: sortedReviews[i].ranking = .first
                            case 1: sortedReviews[i].ranking = .second
                            case 2: sortedReviews[i].ranking = .third
                            default: sortedReviews[i].ranking = nil
                            }
                        }
                        
                        self.friendReviews.append(contentsOf: sortedReviews)
                    }
                }
            } catch {
                print("❌ Error fetching reviews!")
            }
        }
    }
    
    
    func refreshReviewFeed() async {
        getAllFriendsReviews()
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
                    (receivedReviews, self.cursor) = try await CloudKitManager.shared.getFriendsReviews(for: friends.map { CKRecord.Reference(recordID: $0.recordID, action: .none) }, passedCursor: self.cursor, sortBy: "date")
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
            } catch {
                print("❌ Error getting friends for reviews")
            }
        }
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
