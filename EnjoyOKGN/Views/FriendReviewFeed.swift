//
//  FriendReviewFeed.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-22.
//

import SwiftUI

struct FriendReviewFeed: View {
    
    @State var reviews: [OKGNReview] = [] {
        didSet {
            print(reviews)
        }
    }
    
    var body: some View {
        List {
            ForEach(reviews) { review in
                ReviewCell(review: review)
            }
        }
//        .onReceive(CloudKitManager.shared.$profileRecordID) { _ in
//            DispatchQueue.main.async {
//                guard let profileID = CloudKitManager.shared.profileRecordID else {
//                    print("😟 could not get profileID")
//                    return
//                }
//                CloudKitManager.shared.getUserReviews(for: profileID) { result in
//                    switch result {
//                    case .success(let receivedReviews):
//                        reviews = receivedReviews
//                    case .failure(_):
//                        print("😞 could not get reviews for friend feed")
//                    }
//                }
//            }
//
//        }
        .onAppear {
            DispatchQueue.main.async {
                guard let profileID = CloudKitManager.shared.profileRecordID else {
                    print("😟 could not get profileID")
                    return
                }
                CloudKitManager.shared.getUserReviews(for: profileID) { result in
                    switch result {
                    case .success(let receivedReviews):
                        reviews = receivedReviews
                    case .failure(_):
                        print("😞 could not get reviews for friend feed")
                    }
                }
            }
        }
    }
}

struct FriendReviewFeed_Previews: PreviewProvider {
    static var previews: some View {
        FriendReviewFeed(reviews: [MockData.pizzeriaReview1.convertToOKGNReview()])
    }
}
