//
//  FriendProfileViewModel.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-03-17.
//

import Foundation


final class FriendProfileViewModel: ObservableObject {
    
    @Published var isShowingTopRatedFilterAlert = false
    @Published var isShowingDetailedModalView = false
    @Published var topRatedFilter: Category?
    @Published var detailedReviewToShow: OKGNReview?
        
}
