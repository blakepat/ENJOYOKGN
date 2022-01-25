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
    var category: Category
    
}

enum AwardTypes {
    
    static let pizzaAward = Award(name: "El Presidente Award", caption: "Eat at 10 Pizzerias", category: .Pizzeria)
    static let wineryAward = Award(name: "Sommelier Award", caption: "Drink at 10 Wineries", category: .Winery)
    static let breweryAward = Award(name: "Brewmaster Award", caption: "Drink at 10 Breweries", category: .Brewery)
    static let cafeAward = Award(name: "Java Joe Award", caption: "Visit 10 Cafe's", category: .Cafe)
    static let activityAward = Award(name: "Adventurer Award", caption: "Complete 10 Activities", category: .Activity)

    static let awards = [pizzaAward, wineryAward, breweryAward, cafeAward, activityAward]
    
    
    
}
