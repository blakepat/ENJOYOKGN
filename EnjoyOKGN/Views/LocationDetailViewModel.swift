//
//  LocationDetailViewModel.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-15.
//

import SwiftUI


final class LocationDetailViewModel: ObservableObject {
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var location: OKGNLocation
    
    init(location: OKGNLocation) {
        self.location = location
    }
    
}



