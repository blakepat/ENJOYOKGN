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

            guard let userRecord = CloudKitManager.shared.userRecord else {
                // show an alert
                print("no user record for get reviews")
                return
            }

            guard let profileReference = userRecord["userProfile"] as? CKRecord.Reference else {
                return
            }

            let profileRecordID = profileReference.recordID

            CloudKitManager.shared.getUserReviews(for: profileRecordID) { result in

                    switch result {
                    case .success(let reviews):
                        self.reviews = reviews
                        print("✅ REVIEWS SET")
                    case .failure(_):
                        print("❌ Error fetching reviews!")
                    }
            }
        }

    
    func otherGetReviews() {
        guard let profileID = CloudKitManager.shared.profileRecordID else {
            print("😟 could not get profileID")
            return
        }

        CloudKitManager.shared.getUserReviews(for: profileID) { result in
            switch result {
            case .success(let receivedReviews):
                DispatchQueue.main.async {
                    print("✅ REVIEWS SET")
                    self.reviews = receivedReviews
                }
                    

            case .failure(_):
                print("❌ Error fetching reviews!")
            }
        }
    }
    
    
}
