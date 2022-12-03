//
//  FriendProfileViewModel.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-03-17.
//

import SwiftUI
import CloudKit


final class FriendProfileViewModel: ObservableObject {
    
    @ObservedObject var friendManager = FriendManager()
    
    @Published var isShowingTopRatedFilterAlert = false
    @Published var isShowingDetailedModalView = false
    @Published var topRatedFilter: Category?
    @Published var detailedReviewToShow: OKGNReview?
    @Published var categoryVisitCounts = [0,0,0,0,0]
    @Published var userIsBlocked = false
    
    @Published var friendReviews: [OKGNReview]? {
        didSet {
            setAwards(reviews: friendReviews ?? [])
        }
    }
    
    func setAwards(reviews: [OKGNReview]) {
        withAnimation(.linear(duration: 3)) {
        
            for i in 0..<categoryVisitCounts.count {
                categoryVisitCounts[i] = reviews.filter( {$0.locationCategory == categories[i].description }).count
            }
        }
    }
    
    
    func blockUser(_ user: CKRecord.Reference) {
        friendManager.blockUser(user)
        userIsBlocked = true
    }
    
    func unBlockUser(_ user: CKRecord.Reference) {
        friendManager.unBlockUser(user)
        userIsBlocked = false
    }
}



