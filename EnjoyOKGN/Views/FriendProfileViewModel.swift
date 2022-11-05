//
//  FriendProfileViewModel.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-03-17.
//

import SwiftUI


final class FriendProfileViewModel: ObservableObject {
    
    @Published var isShowingTopRatedFilterAlert = false
    @Published var isShowingDetailedModalView = false
    @Published var topRatedFilter: Category?
    @Published var detailedReviewToShow: OKGNReview?
    
//    @Published var wineryCount = 0
//    @Published var breweryCount = 0
//    @Published var cafeCount = 0
//    @Published var pizzeriaCount = 0
//    @Published var activityCount = 0
    
    @Published var categoryVisitCounts = [0,0,0,0,0]
    
    @Published var friendReviews: [OKGNReview]? {
        didSet {
            setAwards(reviews: friendReviews ?? [])
//            wineryCount = friendReviews?.filter({returnCategoryFromString($0.locationCategory) == .Winery}).count ?? 0
//            breweryCount = friendReviews?.filter({returnCategoryFromString($0.locationCategory) == .Brewery}).count ?? 0
//            cafeCount = friendReviews?.filter({returnCategoryFromString($0.locationCategory) == .Cafe}).count ?? 0
//            pizzeriaCount = friendReviews?.filter({returnCategoryFromString($0.locationCategory) == .Pizzeria}).count ?? 0
//            activityCount = friendReviews?.filter({returnCategoryFromString($0.locationCategory) == .Activity}).count ?? 0
        }
    }
    
    func setAwards(reviews: [OKGNReview]) {
        withAnimation(.linear(duration: 3)) {
        
            for i in 0..<categoryVisitCounts.count {
                categoryVisitCounts[i] = reviews.filter( {$0.locationCategory == categories[i].description }).count
            }
        }
    }
    
}



