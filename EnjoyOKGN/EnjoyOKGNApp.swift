//
//  STOKGNApp.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-01-21.
//

import SwiftUI

@main
struct STOKGNApp: App {
    
    let locationManager = LocationManager()
    @ObservedObject var reviewManager = ReviewManager()
    @State private var showLaunchScreen = true

    
    
    var body: some Scene {
        WindowGroup {
            
            ZStack {
                TabBarView().environmentObject(locationManager).environmentObject(reviewManager)
                
                ZStack {
                    if showLaunchScreen {
                        LaunchView(showLaunchScreen: $showLaunchScreen)
                            .transition(.move(edge: .leading))
                    }
                }
                .zIndex(2)
            }
        }
    }
}
