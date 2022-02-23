//
//  FriendReviewFeed.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-22.
//

import SwiftUI

struct FriendReviewFeed: View {
    
    @EnvironmentObject var reviewManager: ReviewManager
    
    var body: some View {
        List {
            ForEach(reviewManager.reviews) { review in
                ReviewCell(review: review)
            }
        }
        .onAppear {
            reviewManager.otherGetReviews()
        }
    }
}

//struct FriendReviewFeed_Previews: PreviewProvider {
//    static var previews: some View {
//        FriendReviewFeed(reviewManager: ReviewManager())
//    }
//}
