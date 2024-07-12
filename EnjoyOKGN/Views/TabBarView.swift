//
//  TabBarView.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-02-03.
//

import SwiftUI

struct TabBarView: View {
    
    @StateObject private var viewModel = TabBarViewModel()
    @StateObject var profileManager = ProfileManager()
    @StateObject var locationManager = LocationManager()
    
    @State private var tabSelection: TabBarItem = .home
    
    var body: some View {
        CustomTabBarContainerView(selection: $tabSelection) {
            HomePageView(tabSelection: $tabSelection).environmentObject(profileManager).environmentObject(locationManager)
                .tabBarItem(tab: .home, selection: $tabSelection)
            
            FriendReviewFeed(tabSelection: $tabSelection).environmentObject(profileManager)
                .tabBarItem(tab: .feed, selection: $tabSelection)
            
            CreateReviewView(date: Date(), locations: [], tabSelection: $tabSelection).environmentObject(profileManager).environmentObject(locationManager)
                .tabBarItem(tab: .create, selection: $tabSelection)
            
            MapView(tabSelection: $tabSelection)
                .tabBarItem(tab: .map, selection: $tabSelection)
            
            LocationListView(locations: [], tabSelection: $tabSelection)
                .tabBarItem(tab: .list, selection: $tabSelection)
        }
        .fullScreenCover(isPresented: $viewModel.isShowingOnboardView) {
            OnboardView()
        }
        .task {
            try? await CloudKitManager.shared.getUserRecord() 
            
            if !viewModel.hasSeenOnboardView {
                viewModel.isShowingOnboardView = true
                UserDefaults.standard.set(true, forKey: "hasSeenOnboardView")
            }
        }
        .alert(viewModel.alertItem?.title ?? Text(""), isPresented: $viewModel.showAlertView, actions: {
            // actions
        }, message: {
            viewModel.alertItem?.message ?? Text("")
        })
        
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
