//
//  AwardData.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-01-22.
//

import SwiftUI

struct Award {
    var name: String
    var caption: String
    var color: Color
}

enum AwardTypes {
    
    static let pizzaAward = Award(name: "El Presidente Award", caption: "Eat at 10 Pizzerias", color: Color.OKGNPink)
    static let wineryAward = Award(name: "Sommelier Award", caption: "Drink at 10 Wineries", color: Color.OKGNPurple)
    static let breweryAward = Award(name: "Brewmaster Award", caption: "Drink at 10 Breweries", color: Color.OKGNPeach)
    static let cafeAward = Award(name: "Java Joe Award", caption: "Visit 10 Cafe's", color: Color.OKGNDarkYellow)
    static let activityAward = Award(name: "Adventurer Award", caption: "Complete 10 Activities", color: Color.OKGNLightYellow)

    static let awards = [pizzaAward, wineryAward, breweryAward, cafeAward, activityAward]
    
    
    
}
