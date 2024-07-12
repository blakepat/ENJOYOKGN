//
//  MapViewModel.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-02-09.
//

import SwiftUI
import MapKit
import CoreLocation

final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
//    @Published var kelownaCenter = CLLocationCoordinate2D(latitude: 49.8853, longitude: -119.4947)
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 49.8853, longitude: -119.4947),
                                                   span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08))
    
    @Published var alertItem: AlertItem?
    @Published var showAlertView = false
    @Published var isShowingLocationDetailView = false
    @Published var locationCategoryFilter: Category?
    @Published var isShowingFilterModal = false
    @Published var showLoadingView = false
    
    var deviceLocationManager: CLLocationManager?
    
    @Published var centerOnUser: MKUserTrackingMode?
    
    func checkIfLocationServicesIsEnabled() {
        DispatchQueue.global().async { [self] in
            if CLLocationManager.locationServicesEnabled() {
                deviceLocationManager = CLLocationManager()
                deviceLocationManager!.delegate = self
            } else {
                DispatchQueue.main.async { [self] in
                    alertItem = AlertContext.locationDisabled
                    showAlertView = true
                }
            }
        }
    }
    
    override init() {
        super.init()
        deviceLocationManager?.delegate = self
        locationManager.delegate = self
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        
        withAnimation {
            region = MKCoordinateRegion(center: currentLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            
        }
    }
    
    
    func centerOnUsersLocation() {
        locationManager.requestLocation()
        print("❤️ Center on user location called!")
        centerOnUser = MKUserTrackingMode.follow
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("❌ Error centering on users location")
    }
    
    
    func getLocationAuthorization(manager: CLLocationManager) {
        guard let deviceLocationManager = deviceLocationManager else { return }
        
        switch deviceLocationManager.authorizationStatus {
            
        case .notDetermined:
            deviceLocationManager.requestWhenInUseAuthorization()
        case .restricted:
            alertItem = AlertContext.locationRestricted
            showAlertView = true
        case .denied:
            alertItem = AlertContext.locationDenied
            showAlertView = true
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    
    @MainActor func getLocations(for locationManager: LocationManager) {
        Task {
            do {
                showLoadingView = true
                locationManager.locations = try await CloudKitManager.shared.getLocations() { (returnedBool) in
                    DispatchQueue.main.async {
                        self.showLoadingView = returnedBool
                    }
                }
            } catch {
                //TO-DO: create alert
                print("❌ unable to get locations for mapview")
                alertItem = AlertContext.cannotRetrieveLocations
                showAlertView = true
                showLoadingView = false
            }
        }
    }
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        getLocationAuthorization(manager: manager)
    }
}
