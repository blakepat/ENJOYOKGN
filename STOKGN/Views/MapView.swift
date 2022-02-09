//
//  MapView.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-02-07.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 49.8853, longitude: -119.4947),
                                                   span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
    
    var body: some View {
        ZStack {
            
            Map(coordinateRegion: $region)
                .edgesIgnoringSafeArea(.top)
            
        }
        .onAppear {
            CloudKitManager.getLocations { result in
                switch result {
                    
                case .success(let locations):
                    print(locations)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
