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
    
//    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var centerCoordinate: MKCoordinateRegion
    @Binding var showDetailedView: Bool
    @Binding var selectedPlace: OKGNLocation?
    @Binding var okgnLocations: [OKGNLocation]
    
    var annotations: [MKPointAnnotation]
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: NewMapView
        
        init(_ parent: NewMapView) {
            self.parent = parent
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            parent.centerCoordinate.center = mapView.centerCoordinate
        }
        
        
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            let identifier = "Placemark"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                
                annotationView = LocationMarkerView(annotation: annotation, reuseIdentifier: identifier)
                
//                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//                annotationView?.canShowCallout = true
//                annotationView?.tintColor = UIColor(returnCategoryFromString(((annotation.subtitle ?? "Brewery")!)).color)
//                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            } else {
                annotationView?.annotation = annotation
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
//        mapView.userTrackingMode = .followWithHeading
//        mapView.setUserTrackingMode(.followWithHeading, animated: true)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if annotations.count != uiView.annotations.count || annotations.first?.subtitle != uiView.annotations.first?.subtitle {
            uiView.removeAnnotations(uiView.annotations)
            uiView.addAnnotations(annotations)
        }
        
        uiView.region.center = self.centerCoordinate.center
        
        if uiView.region.span.latitudeDelta > 100 {
            uiView.region.span = MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
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


//
//struct NewMapView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewMapView(centerCoordinate: .constant(MKPointAnnotation.example.coordinate ), annotations: [MKPointAnnotation.example])
//    }
//}



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
