//
//  MapView.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-02-07.
//

import SwiftUI
import MapKit
import CoreLocation
import CoreLocationUI

struct MapView: View {
    
    @EnvironmentObject private var locationManager: LocationManager
    @StateObject private var viewModel = MapViewModel()
    @EnvironmentObject var reviewManager: ReviewManager
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    @State private var locations = [MKPointAnnotation]()
    @State private var selectedLocation: MKPointAnnotation?
    @Binding var tabSelection: TabBarItem
    
    
    var body: some View {
        ZStack {
            
            NewMapView(centerCoordinate: $viewModel.region, showDetailedView: $viewModel.isShowingLocationDetailView, selectedPlace: $locationManager.selectedLocation,  okgnLocations:
                        $locationManager.locations, centerOnUserLocation: $viewModel.centerOnUser, annotations: locations.filter({viewModel.locationCategoryFilter != nil ? returnCategoryFromString($0.subtitle ?? "") == viewModel.locationCategoryFilter : true}))
                .edgesIgnoringSafeArea(.all) 
                        
            VStack {
                HStack(alignment: .top) {
                    Button {
                        viewModel.isShowingFilterModal.toggle()
                    } label: {
                        ZStack {
                            Image(systemName: "line.3.horizontal.circle")
                                .resizable()
                                .shadow(color: .black, radius: 30, x: 0, y: 0)
                                .background(
                                    Circle()
                                        .stroke(lineWidth: 3)
                                        .colorMultiply(.black.opacity(0.3))
                                )
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                                .padding(.top, 20)
                                .padding(.leading, 8)
                        }
                    }
                    Spacer()
                }
                .padding(.leading)
                Spacer()
            }
            .padding(.top)
            
            SideMenuView(categoryFilter: $viewModel.locationCategoryFilter, menuOpen: $viewModel.isShowingFilterModal)
            
            
            if viewModel.showLoadingView {
                GeometryReader { _ in
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            LoadingView()
                            Spacer()
                        }
                        Spacer()
                    }
                }
                .background(Color.black.opacity(0.45)).edgesIgnoringSafeArea(.all)
            }
            
        }
        .overlay(alignment: .bottomLeading) {
            LocationButton {
                viewModel.centerOnUsersLocation()
            }
            .foregroundColor(.white)
            .symbolVariant(.fill)
            .tint(.OKGNDarkYellow)
            .labelStyle(.iconOnly)
            .clipShape(Circle())
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 60, trailing: 0))
        }
        .alert(viewModel.alertItem?.title ?? Text(""), isPresented: $viewModel.showAlertView, actions: {
            // actions
        }, message: {
            viewModel.alertItem?.message ?? Text("")
        })
        .sheet(isPresented: $viewModel.isShowingLocationDetailView, content: {
            
            NavigationView {
                createLocationDetailView(for: locationManager.selectedLocation, in: sizeCategory)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Dismiss") {
                                viewModel.isShowingLocationDetailView = false
                            }
                        }
   
                    }
            }
            .accentColor(.OKGNDarkYellow)
        })
        .onChange(of: tabSelection, perform: { newValue in
            if newValue == .map {
                viewModel.checkIfLocationServicesIsEnabled()
                if locationManager.locations.isEmpty {
                    viewModel.showLoadingView = true
                    viewModel.getLocations(for: locationManager)
                }
            }
        })
        .onReceive(locationManager.$locations) { updatedLocations in
            
            viewModel.showLoadingView = false
            
            for place in updatedLocations {
                let newLocation = MKPointAnnotation()
                newLocation.title = place.name
                newLocation.subtitle = place.category
                newLocation.coordinate = place.location.coordinate
                locations.append(newLocation)
            }
        }
    }
    
    
    @ViewBuilder func createLocationDetailView(for location: OKGNLocation?, in sizeCategory: DynamicTypeSize) -> some View {
        if sizeCategory >= .accessibility2 {
            LocationDetailView(viewModel: LocationDetailViewModel(location: location)).embedInScrollView()
        } else {
            LocationDetailView(viewModel: LocationDetailViewModel(location: location))
        }
    }
}




//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}


