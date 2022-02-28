//
//  LocationDetailViewModel.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-15.
//

import SwiftUI
import MapKit


final class LocationDetailViewModel: ObservableObject {
    
    @Published var isShowingDetailedModalView = false
    @Published var detailedReviewToShow: OKGNReview?
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 1)
    @Published var reviews: [OKGNReview]
    
    var location: OKGNLocation
    @Published var alertItem: AlertItem?
    
    
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
    
}



