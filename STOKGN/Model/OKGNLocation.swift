//
//  OKGNLocation.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-02-07.
//

import UIKit
import CloudKit


struct OKGNLocation: Identifiable {
    
    static let kName = "name"
    static let kDescription = "description"
    static let kSquareAsset = "squareAsset"
    static let kBannerAsset = "bannerAsset"
    static let kAddress = "address"
    static let kLocation = "location"
    static let kWebsiteURL = "websiteURL"
    static let kPhoneNumber = "phoneNumber"
    static let kCategory = "category"
    static let kCategoryTwo = "categoryTwo"
    
    
    let id: CKRecord.ID
    let name: String
    let description: String
    let squareAsset: CKAsset!
    let bannerAsset: CKAsset!
    let address: String
    let location: CLLocation
    let websiteURL: String
    let phoneNumber: String?
    let category: String
    let categoryTwo: String?
    
    
    init(record: CKRecord) {
        id  = record.recordID
        name        = record[OKGNLocation.kName] as? String ?? "N/A"
        description = record[OKGNLocation.kDescription] as? String ?? "N/A"
        squareAsset = record[OKGNLocation.kSquareAsset] as? CKAsset
        bannerAsset = record[OKGNLocation.kBannerAsset] as? CKAsset
        address     = record[OKGNLocation.kAddress] as? String ?? "N/A"
        location    = record[OKGNLocation.kLocation] as? CLLocation ?? CLLocation(latitude: 0, longitude: 0)
        websiteURL  = record[OKGNLocation.kWebsiteURL] as? String ?? "N/A"
        phoneNumber = record[OKGNLocation.kPhoneNumber] as? String
        category    = record[OKGNLocation.kCategory] as? String ?? "Activity"
        categoryTwo = record[OKGNLocation.kCategoryTwo] as? String
    }
    
    
    func createSquareImage() -> UIImage {
        guard let asset = squareAsset else { return PlaceholderImage.square }
        return asset.convertToUIImage(in: .square)
    }
    
    
    func createBannerImage() -> UIImage {
        guard let asset = bannerAsset else { return PlaceholderImage.banner }
        return asset.convertToUIImage(in: .banner)
    }
    
}
