//
//  LocationManager.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-02-09.
//

import Foundation
import CloudKit
import UIKit


final class LocationManager: ObservableObject {
        
    @Published var locations: [OKGNLocation] = []
    @Published var selectedLocation: OKGNLocation?
    @Published var locationNamesIdsCategory = [(CKRecord.ID, String, String)]() {
        didSet {
            print("✅✅ location names and Ids SET!")
            print(locationNamesIdsCategory[0].1)
        }
    }
    
    @Published var locationsToUpload: [CKRecord] = []
    let randomFileName = "locations3"
    
    
    
    
    
//    USED TO MIGRATE DATA FROM DEVELOPMENT TO PRODUCTION
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    func saveLocations(locationsToSave: [OKGNLocation]) {
        
        var convertedLocations: [NSLocation] = []
//        let _ = locationsToSave.map({ convertedLocations.append(NSLocation(location: $0)) })
        
        for location in locationsToSave {
            convertedLocations.append(NSLocation(location: location))
        }
        
        let fullPath = getDocumentsDirectory().appendingPathComponent(randomFileName)
//        for location in convertedLocations {
////            print(location.latitude)
//        }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: convertedLocations, requiringSecureCoding: false)
            try data.write(to: fullPath)
        } catch (let error) {
            print("Couldn't write file \(error)")
        }
    }
    
    
//    func uploadLocations() async {
//        print("UPLOAD LOCATIONS CALLED")
//        let fullPath = getDocumentsDirectory().appendingPathComponent(randomFileName)
//        do {
//            let data = try Data(contentsOf: fullPath)
//            if let loadedLocations = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [NSLocation] {
////            if let loadedLocations = try NSKeyedUnarchiver.unarchiveObject(withFile: randomFileName) as? [NSLocation] {
//                print(loadedLocations)
//                if loadedLocations.isEmpty { print("isEMPTY!!!")}
//                for location in loadedLocations {
//                    
////                    print(location.longitude)
//                    
//                    let latLong = CLLocation(latitude: Double(location.latitude) ?? 0, longitude: Double(location.longitude) ?? 0)
//                    let squarePhoto = UIImage(data: location.squareAsset as Data)?.convertToCKAsset(path: "\(location.name)squareAsset")
//                    let bannerPhoto = UIImage(data: location.bannerAsset as Data)?.convertToCKAsset(path: "\(location.name)bannerAsset")
//                    
//                    let CKLocation = CKRecord(recordType: RecordType.location)
//                    CKLocation[OKGNLocation.kName] = location.name
//                    CKLocation[OKGNLocation.kDescription] = location.locationDescription
//                    CKLocation[OKGNLocation.kSquareAsset] = squarePhoto
//                    CKLocation[OKGNLocation.kBannerAsset] = bannerPhoto
//                    CKLocation[OKGNLocation.kAddress] = location.address
//                    CKLocation[OKGNLocation.kLocation] = latLong
//                    CKLocation[OKGNLocation.kWebsiteURL] = location.websiteURL
//                    CKLocation[OKGNLocation.kPhoneNumber] = location.phoneNumber
//                    CKLocation[OKGNLocation.kCategory] = location.category
//
//                    self.locationsToUpload.append(CKLocation)
//                    
//                }
//                
//                if let _ = try await CloudKitManager.shared.batchSave(records: self.locationsToUpload) {
//                    print(self.locationsToUpload)
//                }
//            } else {
//                print("😈😈 unable to get loadedLocaions")
//            }
//        } catch {
//            print("Couldn't read file.")
//        }
//        
//    }
    func uploadLocations() async {
        print("UPLOAD LOCATIONS CALLED")
        let fullPath = getDocumentsDirectory().appendingPathComponent(randomFileName)
        do {
            let data = try Data(contentsOf: fullPath)
            if let loadedLocations = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data) as? [NSLocation] {
                print(loadedLocations)
                if loadedLocations.isEmpty { print("isEMPTY!!!") }
                for location in loadedLocations {
                    let latLong = CLLocation(latitude: Double(location.latitude) ?? 0, longitude: Double(location.longitude) ?? 0)
                    let squarePhoto = UIImage(data: location.squareAsset as Data)?.convertToCKAsset(path: "\(location.name)squareAsset")
                    let bannerPhoto = UIImage(data: location.bannerAsset as Data)?.convertToCKAsset(path: "\(location.name)bannerAsset")
                    
                    let CKLocation = CKRecord(recordType: RecordType.location)
                    CKLocation[OKGNLocation.kName] = location.name
                    CKLocation[OKGNLocation.kDescription] = location.locationDescription
                    CKLocation[OKGNLocation.kSquareAsset] = squarePhoto
                    CKLocation[OKGNLocation.kBannerAsset] = bannerPhoto
                    CKLocation[OKGNLocation.kAddress] = location.address
                    CKLocation[OKGNLocation.kLocation] = latLong
                    CKLocation[OKGNLocation.kWebsiteURL] = location.websiteURL
                    CKLocation[OKGNLocation.kPhoneNumber] = location.phoneNumber
                    CKLocation[OKGNLocation.kCategory] = location.category

                    self.locationsToUpload.append(CKLocation)
                }
                
                if let _ = try await CloudKitManager.shared.batchSave(records: self.locationsToUpload) {
                    print(self.locationsToUpload)
                }
            } else {
                print("😈😈 unable to get loadedLocations")
            }
        } catch {
            print("Couldn't read file: \(error)")
        }
    }
}


