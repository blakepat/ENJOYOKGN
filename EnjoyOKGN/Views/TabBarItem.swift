//
//  TabBarItem.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-11-04.
//

import Foundation
import SwiftUI


enum TabBarItem: Hashable {
    
    case home, feed, create, map, list
    
    var iconName: String {
        switch self {
            case .home : return "house.fill"
            case .feed : return "person.3.fill"
            case .create : return "plus.circle"
            case .map : return "map"
            case .list : return "list.bullet"
        }
    }
    
    var title: String {
        switch self {
        case .home : return "Home"
        case .feed : return "Friends"
        case .create : return "Review"
        case .map : return "Map"
        case .list : return "Locations"
        }
    }
    
    var color: Color {
        switch self {
            case .home : return Color.OKGNDarkYellow
            case .feed : return Color.OKGNPurple
            case .create : return Color.OKGNLightGreen
            case .map : return Color.OKGNPink
            case .list : return Color.OKGNPeach
        }
    }
    
    
    
}

//TabView {
//    HomePageView().environmentObject(profileManager).environmentObject(locationManager)
//        .tabItem {
//            Label("Home", systemImage: "house.fill")
//        }
//
//    FriendReviewFeed().environmentObject(profileManager)
//        .tabItem {
//            Label("Friends", systemImage: "person.3.fill")
//        }
//
//    CreateReviewView(date: Date(), locations: []).environmentObject(profileManager).environmentObject(locationManager)
//        .tabItem {
//            Label("Review", systemImage: "plus.circle")
//        }
//
//    MapView()
//        .tabItem {
//            Label("Map", systemImage: "map")
//        }
//
//    LocationListView(locations: [])
//        .tabItem {
//            Label("Locations", systemImage: "list.bullet")
