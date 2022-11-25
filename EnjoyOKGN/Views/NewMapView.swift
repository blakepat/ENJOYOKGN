//
//  NewMapView.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-09-07.
//

import Foundation
import SwiftUI
import MapKit


struct NewMapView: UIViewRepresentable {
    
    @Binding var centerCoordinate: MKCoordinateRegion
    @Binding var showDetailedView: Bool
    @Binding var selectedPlace: OKGNLocation?
    @Binding var okgnLocations: [OKGNLocation]
    @Binding var centerOnUserLocation: MKUserTrackingMode?
    
    var startingRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 49.8853, longitude: -119.4947),
                                        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08))
    
    var annotations: [MKPointAnnotation]
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: NewMapView
        
        init(_ parent: NewMapView) {
            self.parent = parent
        }
        
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            DispatchQueue.main.async {
                self.parent.centerCoordinate.center = mapView.centerCoordinate
            }
            
        }
        
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "Placemark"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotation.title == "My Location"  {
                return nil
            } else {
                if annotationView == nil {
                    annotationView = LocationMarkerView(annotation: annotation, reuseIdentifier: identifier)
                } else {
                    annotationView?.annotation = annotation
                }
            }
            
            return annotationView
        }
        
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let placemark = view.annotation as? MKPointAnnotation else { return }
            parent.selectedPlace = parent.okgnLocations.first {$0.name == placemark.title ?? "" }
            parent.showDetailedView = true
        }
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.pointOfInterestFilter = .excludingAll
        mapView.region = centerCoordinate
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.region.span = MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)

        mapView.setRegion(startingRegion, animated: false)
        
        return mapView
    }
    
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
        if annotations.count + 1 != uiView.annotations.count || !(uiView.annotations.contains(where: {$0.subtitle == annotations.first?.subtitle })) {
            
            uiView.removeAnnotations(uiView.annotations)
            uiView.addAnnotations(annotations)
        }
        
        if let centerOnUserLocation = centerOnUserLocation {
            uiView.userTrackingMode = centerOnUserLocation
            self.centerOnUserLocation = nil
            uiView.userTrackingMode = .none
        }
    }
}


extension MKPointAnnotation {
    static var example: MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = "London"
        annotation.subtitle = "Home to 2012 Olympics"
        annotation.coordinate = CLLocationCoordinate2D(latitude: 51.5, longitude: -0.13)
        return annotation
    }
}



class LocationMarkerView: MKMarkerAnnotationView {
  override var annotation: MKAnnotation? {
    willSet {
        guard let marker = newValue as? MKPointAnnotation else {
            return
        }
        
        tintColor = UIColor(returnCategoryFromString(marker.subtitle ?? "Brewery").color)
        canShowCallout = true
        rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        markerTintColor = UIColor(returnCategoryFromString(marker.subtitle ?? "Brewery").color)
    }
  }
}
