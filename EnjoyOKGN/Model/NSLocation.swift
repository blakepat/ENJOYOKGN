//
//  NSLocation.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-12-07.
//

import Foundation


class NSLocation: NSObject, NSCoding {
    
    var name: String
    let locationDescription: String
    let squareAsset: NSData
    let bannerAsset: NSData
    let address: String
    let latitude: String
    let longitude: String
    let websiteURL: String
    let phoneNumber: String?
    let category: String
    
    init(location: OKGNLocation) {
        self.name = location.name
        self.locationDescription = location.description
        
        let squareData = location.squareAsset.convertToUIImage(in: .square).pngData()!
        let bannerData = location.bannerAsset.convertToUIImage(in: .banner).pngData()!
        
        self.squareAsset = NSData(data: squareData)
        self.bannerAsset = NSData(data: bannerData)
        self.address = location.address
        self.latitude = "\(location.location.coordinate.latitude)"
        self.longitude = "\(location.location.coordinate.longitude)"
        self.websiteURL = location.websiteURL
        self.phoneNumber = location.phoneNumber
        self.category = location.category
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(locationDescription, forKey: "locationDescription")
        coder.encode(squareAsset, forKey: "squareAsset")
        coder.encode(bannerAsset, forKey: "bannerAsset")
        coder.encode(address, forKey: "address")
        coder.encode(latitude, forKey: "latitude")
        coder.encode(longitude, forKey: "longitude")
        coder.encode(websiteURL, forKey: "websiteURL")
        coder.encode(phoneNumber, forKey: "phoneNumber")
        coder.encode(category, forKey: "category")
    }
    
    required init?(coder: NSCoder) {
        name = coder.decodeObject(forKey: "name") as? String ?? ""
        locationDescription = coder.decodeObject(forKey: "locationDescription") as? String ?? ""
        squareAsset = coder.decodeObject(forKey: "squareAsset") as! NSData
        bannerAsset = coder.decodeObject(forKey: "bannerAsset") as! NSData
        address = coder.decodeObject(forKey: "address") as? String ?? ""
        latitude = coder.decodeObject(forKey: "latitude") as? String ?? ""
        longitude = coder.decodeObject(forKey: "longitude") as? String ?? ""
        websiteURL = coder.decodeObject(forKey: "websiteURL") as? String ?? ""
        phoneNumber = coder.decodeObject(forKey: "phoneNumber") as? String
        category = coder.decodeObject(forKey: "category") as? String ?? ""
    }
}
