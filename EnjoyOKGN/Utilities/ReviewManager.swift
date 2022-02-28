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
    @Published var friendsReviews: [OKGNReview] = []
    
    func getUserReviews() {
        guard let profileID = CloudKitManager.shared.profileRecordID else {
            print("❌ could not get profileID")
            return
        }

        CloudKitManager.shared.getUserReviews(for: profileID) { result in
            switch result {
            case .success(let receivedReviews):
                DispatchQueue.main.async {
                    print("✅ REVIEWS SET")
                    
                    self.userReviews = []
                    
                    for category in categories {
                        var sortedReviews: [OKGNReview] = receivedReviews.filter({returnCategoryFromString($0.locationCategory) == category}).sorted { $0.rating > $1.rating }
                        for i in 0..<min(sortedReviews.count, 3) {
                            sortedReviews[i].ranking = rankings[i]
                        }
                        self.userReviews.append(contentsOf: sortedReviews)
                    }
                }                    

            case .failure(_):
                print("❌ Error fetching reviews!")
            }
        }
    }
    
    func getFriendsReviews() {
        guard let profile = CloudKitManager.shared.profile else {
            print("❌ could not get profileID")
            return
        }
        
        CloudKitManager.shared.getFriendsReviews(for: CloudKitManager.shared.profile?.convertToOKGNProfile().friends ?? []) { result in
            switch result {
            case .success(let receivedReviews):
                DispatchQueue.main.async {
                    print("✅✅ FRIENDS REVIEWS SET")
                    
                    self.friendsReviews = []
                    self.friendsReviews.append(contentsOf: receivedReviews.sorted { $0.date > $1.date } )
                }

            case .failure(_):
                print("❌ Error fetching reviews!")
            }
        }
    }
    
    func deleteReview(recordID: CKRecord.ID) {
        
    }
    
}
