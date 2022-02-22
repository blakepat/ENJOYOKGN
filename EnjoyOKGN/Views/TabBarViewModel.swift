//
//  TabBarViewModel.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-21.
//

import Foundation

final class TabBarViewModel: ObservableObject {
    
    @Published var alertItem: AlertItem?
    
    @Published var isShowingOnboardView = false
    var hasSeenOnboardView: Bool {
        return UserDefaults.standard.bool(forKey: "hasSeenOnboardView")
    }
}
