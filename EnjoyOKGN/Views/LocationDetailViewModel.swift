//
//  LocationDetailViewModel.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-15.
//

import SwiftUI
import MapKit
import CloudKit


final class LocationDetailViewModel: ObservableObject {
    
    @Published var isShowingDetailedModalView = false
    @Published var detailedReviewToShow: OKGNReview?
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 1)
    @Published var reviews: [OKGNReview]
    
    var location: OKGNLocation
    @Published var alertItem: AlertItem?
    
    @Published var isFavourited = false
    
    
    init(location: OKGNLocation, reviews: [OKGNReview]) {
        self.location = location
        self.reviews = reviews
    }
    
    func getDirectionsToLocation() {
        
        let placemark = MKPlacemark(coordinate: location.location.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = location.name
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    
    func callLocation() {
        //TO-DO: uncomment code and remove other guard let
        
//        guard let url = URL(string: "tel://\(location.phoneNumber)")
        guard let testURL = URL(string: "tel://905-407-1413") else {
            alertItem = AlertContext.invalidPhoneNumber
            return
        }
        if UIApplication.shared.canOpenURL(testURL) {
            UIApplication.shared.open(testURL)
        } else {
            alertItem = AlertContext.unableToCallWithDevice
        }
        
    }
    
    func checkIfLocationIsFavourited() {
        
        guard let profileRecord = CloudKitManager.shared.profile else {
            //TO-DO: create alert for unable to get profile
            return
        }
        
        print(profileRecord.convertToOKGNProfile().favouriteLocations)
        
        if profileRecord.convertToOKGNProfile().favouriteLocations.contains(where: { $0 == CKRecord.Reference(recordID: location.id, action: .none) }) {
            isFavourited = true
        } else {
            isFavourited = false
        }
        
    }
    
    
    func favouriteLocation() {
        
        guard let profileRecord = CloudKitManager.shared.profile else {
            //TO-DO: create alert for unable to get profile
            return
        }
        
        profileRecord[OKGNProfile.kFavouriteLocations] = [CKRecord.Reference(recordID: location.id, action: .none)]
        
        Task {
            do {
                let _ = try await CloudKitManager.shared.save(record: profileRecord)
                alertItem = AlertContext.locationFavouritedSuccess
            } catch {
                alertItem = AlertContext.locationFavouritedFailed
            }
        }
    }
    
    
    func unfavouriteLocation() {
        
        guard let profileRecord = CloudKitManager.shared.profile else {
            //TO-DO: create alert for unable to get profile
            return
        }
        
        var locations: [CKRecord.Reference] = []
        
        for savedLocation in profileRecord.convertToOKGNProfile().favouriteLocations where savedLocation.recordID != location.id {
            locations.append(savedLocation)
        }
        
        profileRecord[OKGNProfile.kFavouriteLocations] = locations
        
        Task {
            do {
                let _ = try await CloudKitManager.shared.save(record: profileRecord)
                alertItem = AlertContext.locationUnfavouritedSuccess
            } catch {
                alertItem = AlertContext.locationUnfavouritedFailed
            }
        }
    }
}



