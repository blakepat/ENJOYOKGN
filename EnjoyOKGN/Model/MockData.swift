//
//  MockUser.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-01-22.
//

import SwiftUI
import CloudKit


enum MockData {
    
    //Mock Users
//    static let mockUser = User(name: "Blake Pat")
    
    //Mock Locations
//    static let mockPizzeriaLocation = Location(name: "Lorenzio's Pizzeria", category: .Pizzeria, image: UIImage(imageLiteralResourceName: "MockLocationPhoto"))
//    static let mockPizzeriaLocation2 = OKGNLocation(name: "Jack Knife", category: .Pizzeria, image: UIImage(imageLiteralResourceName: "MockLocationPhoto"))
//    static let mockPizzeriaLocation3 = Location(name: "Dunnunzies", category: .Pizzeria, image: UIImage(imageLiteralResourceName: "MockLocationPhoto"))
//    static let mockPizzeriaLocation4 = Location(name: "Pizza Pizza", category: .Pizzeria, image: UIImage(imageLiteralResourceName: "MockLocationPhoto"))
//
//
//    static let mockWineryLocation = Location(name: "The Hatch Winery", category: .Winery, image: UIImage(imageLiteralResourceName: "MockLocationPhoto"))
//    static let mockBreweryLocation = Location(name: "Barn Owl", category: .Brewery, image: UIImage(imageLiteralResourceName: "MockLocationPhoto"))
//    static let mockCafeLocation = Location(name: "Slow Side Cafe", category: .Cafe, image: UIImage(imageLiteralResourceName: "MockLocationPhoto"))
//    static let mockActivityLocation = Location(name: "Old Fort", category: .Activity, image: UIImage(imageLiteralResourceName: "MockLocationPhoto"))
//
    
    //Mock Reviews
//
//    static let pizzeriaReview = OKGNReview(location: location.convertToOKGNLocation(), reviewer: mockUser.convertToOKGNProfile(), reviewCaption: "It's gooda pizza", photo: UIImage(imageLiteralResourceName: "MockReviewPhoto"), rating: "9.8", ranking: .first, date: Date().addingTimeInterval(-28000))
    
    static var pizzeriaReview1: CKRecord {

        let record = CKRecord(recordType: RecordType.review)

        record[OKGNReview.kLocation] = CKRecord.Reference(record: location, action: .none)
        record[OKGNReview.kReviewer] = CKRecord.Reference(record: mockUser, action: .none)
        record[OKGNReview.kReviewerName] = "turd"
        record[OKGNReview.kReviewerAvatar] = PlaceholderImage.avatar.convertToCKAsset(path: "profileAvatar")
        record[OKGNReview.klocationName] = "Boston Pizza"
        record[OKGNReview.klocationCategory] = "Pizzeria"
        record[OKGNReview.kCaption] = "Testeroni"
        record[OKGNReview.kPhoto] = PlaceholderImage.square.convertToCKAsset(path: "selectedImage")
        record[OKGNReview.kRating] = "6.6"
        record[OKGNReview.kDate] = Date()

        return record

    }
//
//    static let pizzeriaReview2 = OKGNReview(location: location.convertToOKGNLocation(), reviewer: mockUser.convertToOKGNProfile(), reviewCaption: "the real stuff", photo: UIImage(imageLiteralResourceName: "MockReviewPhoto"), rating: "8.8", ranking: .second, date: Date().addingTimeInterval(-360000))
//
//    static let pizzeriaReview3 = OKGNReview(location: location.convertToOKGNLocation(), reviewer: mockUser.convertToOKGNProfile(), reviewCaption: "boring and bad", photo: UIImage(imageLiteralResourceName: "MockReviewPhoto"), rating: "3.8", ranking: .third, date: Date().addingTimeInterval(-540000))
//
//    static let pizzeriaReview4 = OKGNReview(location: location.convertToOKGNLocation(), reviewer: mockUser.convertToOKGNProfile(), reviewCaption: "boring and bad", photo: UIImage(imageLiteralResourceName: "MockReviewPhoto"), rating: "2.8", date: Date().addingTimeInterval(-5400000))
//
//
//    static let wineryReview = OKGNReview(location: location.convertToOKGNLocation(), reviewer: mockUser.convertToOKGNProfile(), reviewCaption: "Best tasting experience", photo: UIImage(imageLiteralResourceName: "MockReviewPhoto"), rating: "6.5", ranking: .first, date: Date().addingTimeInterval(-99000))
//
//    static let breweryReview = OKGNReview(location: location.convertToOKGNLocation(), reviewer: mockUser.convertToOKGNProfile(), reviewCaption: "Hazy or die", photo: UIImage(imageLiteralResourceName: "MockReviewPhoto"), rating: "9.0", ranking: .first, date: Date().addingTimeInterval(-140000))
//
//    static let cafeReview = OKGNReview(location: location.convertToOKGNLocation(), reviewer: mockUser.convertToOKGNProfile(), reviewCaption: "cute as hell", photo: UIImage(imageLiteralResourceName: "MockReviewPhoto"), rating: "9.9", ranking: .first, date: Date().addingTimeInterval(-12000))
//
//    static let activityReview = OKGNReview(location: location.convertToOKGNLocation(), reviewer: mockUser.convertToOKGNProfile(), reviewCaption: "picturesc", photo: UIImage(imageLiteralResourceName: "MockReviewPhoto"), rating: "7.7", ranking: .first, date: Date().addingTimeInterval(-2000000))
    
    
//    static let mockReviews = [pizzeriaReview, pizzeriaReview2, pizzeriaReview3, pizzeriaReview4, wineryReview, breweryReview, cafeReview, activityReview]
    
    
    
    static var location: CKRecord {
        
        let record = CKRecord(recordType: RecordType.location)
        record[OKGNLocation.kName] = "Boston Pizza"
        record[OKGNLocation.kAddress] = "123 main street, Kelowna"
        record[OKGNLocation.kDescription] = "this is a test and its the best description ever isn't it!"
        record[OKGNLocation.kWebsiteURL] = "https://apple.com"
        record[OKGNLocation.kLocation] = CLLocation(latitude: 49.905433799622166, longitude: -119.49280567123067)
        record[OKGNLocation.kPhoneNumber] = "905-407-1413"
        record[OKGNLocation.kCategory] = "Brewery"
        
        return record
        
    }
    
    
    static var mockUser: CKRecord {
        
        let record = CKRecord(recordType: RecordType.profile)
        record[OKGNProfile.kName] = "Blake Pat"
        record[OKGNProfile.kAvatar] = PlaceholderImage.avatar.convertToCKAsset(path: "profileAvatar")

        return record
        
    }
    
    
}
