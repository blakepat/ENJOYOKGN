//
//  ReviewManager.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-16.
//

import SwiftUI
import CloudKit


final class ReviewManager: ObservableObject {
    
    @Published var reviews: [OKGNReview] = [] 
    
    func getReviews() {
        guard let profileID = CloudKitManager.shared.profileRecordID else {
            print("❌ could not get profileID")
            return
        }

        CloudKitManager.shared.getUserReviews(for: profileID) { result in
            switch result {
            case .success(let receivedReviews):
                DispatchQueue.main.async {
                    print("✅ REVIEWS SET")
                    
                    self.reviews = []
                    
                    for category in categories {
                        var sortedReviews: [OKGNReview] = receivedReviews.filter({returnCategoryFromString($0.locationCategory) == category}).sorted { $0.rating > $1.rating }
                        for i in 0..<min(sortedReviews.count, 3) {
                            sortedReviews[i].ranking = rankings[i]
                        }
                        self.reviews.append(contentsOf: sortedReviews)
                    }
                }                    

            case .failure(_):
                print("❌ Error fetching reviews!")
            }
        }
    }
    
    
}
