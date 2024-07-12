//
//  Review.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-01-24.
//

import Foundation
import UIKit
import CloudKit


struct OKGNReview: Identifiable {
    
    
    static let kCaption = "caption"
    static let kDate = "date"
    static let kLocation = "location"
    static let kPhoto = "photo"
    static let kRating = "rating"
    static let kRanking = "ranking"
    static let kReviewer = "reviewer"
    static let kReviewerName = "reviewerName"
    static let kReviewerAvatar = "reviewerPhoto"
    static let klocationName = "locationName"
    static let klocationCategory = "locationCategory"

    
    let id: CKRecord.ID
    var reviewer: CKRecord.Reference
    var reviewerName: String
    var reviewerAvatar: CKAsset?
    var locationName: String
    var locationCategory: String
    var reviewCaption: String
    var photo: CKAsset!
    var rating: String
    var ranking: Ranking?
    var date: Date
    
    
    init(record: CKRecord) {
        id = record.recordID
        reviewerName = record[OKGNReview.kReviewerName] as? String ?? "N/A"
        reviewerAvatar = record[OKGNReview.kReviewerAvatar] as? CKAsset
        reviewer = record[OKGNReview.kReviewer] as! CKRecord.Reference
        locationName = record[OKGNReview.klocationName] as? String ?? "N/A"
        locationCategory = record[OKGNReview.klocationCategory] as? String ?? "Activity"
        reviewCaption = record[OKGNReview.kCaption] as? String ?? "N/A"
        photo = record[OKGNReview.kPhoto] as? CKAsset
        rating = record[OKGNReview.kRating] as? String ?? "N/A"
//        ranking = record[OKGNReview.kRanking] as? String ?? "0"
        date = record[OKGNReview.kDate] as? Date ?? Date()
    }
}

