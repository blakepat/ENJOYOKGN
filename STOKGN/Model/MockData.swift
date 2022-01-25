//
//  MockUser.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-01-22.
//

import SwiftUI


enum MockData {
    
    //Mock Users
    static let mockUser = User(name: "Blake", photo: UIImage(imageLiteralResourceName: "MockUserPhoto"))
    
    //Mock Locations
    static let mockPizzeriaLocation = Location(name: "Lorenzio's Pizzeria", category: .Pizzeria, image: UIImage(imageLiteralResourceName: "MockLocationPhoto"))
    static let mockWineryLocation = Location(name: "The Hatch Winery", category: .Winery, image: UIImage(imageLiteralResourceName: "MockLocationPhoto"))
    static let mockBreweryLocation = Location(name: "Barn Owl", category: .Brewery, image: UIImage(imageLiteralResourceName: "MockLocationPhoto"))
    static let mockCafeLocation = Location(name: "Slow Side Cafe", category: .Cafe, image: UIImage(imageLiteralResourceName: "MockLocationPhoto"))
    static let mockActivityLocation = Location(name: "Old Fort", category: .Activity, image: UIImage(imageLiteralResourceName: "MockLocationPhoto"))
    
    
    //Mock Reviews
    static let pizzeriaReview = Review(location: mockPizzeriaLocation, reviewer: mockUser, reviewCaption: "It's gooda pizza", photo: UIImage(imageLiteralResourceName: "MockReviewPhoto"), rating: "7.8", isHighest: true)
    
    static let wineryReview = Review(location: mockWineryLocation, reviewer: mockUser, reviewCaption: "Best tasting experience", photo: UIImage(imageLiteralResourceName: "MockReviewPhoto"), rating: "6.5", isHighest: true)
    
    static let breweryReview = Review(location: mockBreweryLocation, reviewer: mockUser, reviewCaption: "Hazy or die", photo: UIImage(imageLiteralResourceName: "MockReviewPhoto"), rating: "9.0", isHighest: true)
    
    static let cafeReview = Review(location: mockCafeLocation, reviewer: mockUser, reviewCaption: "cute as hell", photo: UIImage(imageLiteralResourceName: "MockReviewPhoto"), rating: "9.9", isHighest: true)
    
    static let activityReview = Review(location: mockActivityLocation, reviewer: mockUser, reviewCaption: "picturesc", photo: UIImage(imageLiteralResourceName: "MockReviewPhoto"), rating: "7.7", isHighest: true)
    
    
    static let mockReviews = [pizzeriaReview, wineryReview, breweryReview, cafeReview, activityReview]
    
}
