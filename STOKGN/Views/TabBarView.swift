//
//  TabBarView.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-02-03.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            HomePageView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            
            LocationListView(locations: [])
                .tabItem {
                    Label("Locations", systemImage: "list.bullet")
                }
            
        }
        .accentColor(.OKGNDarkYellow)
        
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
