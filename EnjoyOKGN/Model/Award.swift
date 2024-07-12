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
    var trophy: UIImage!
    
}

let awardImages: [UIImage] = [AwardTypes.pizzeriaAward.trophy, AwardTypes.breweryAward.trophy, AwardTypes.wineryAward.trophy, AwardTypes.cafeAward.trophy, AwardTypes.activityAward.trophy]

enum AwardTypes {
    
    static let pizzeriaAward = Award(name: "El Presidente Award", caption: "Eat at 10 Pizzerias", category: .Pizzeria, trophy: UIImage(named: "PizzeriaTrophy"))
    static let wineryAward = Award(name: "Sommelier Award", caption: "Drink at 10 Wineries", category: .Winery, trophy: UIImage(named:  "WineryTrophy"))
    static let breweryAward = Award(name: "Brewmaster Award", caption: "Drink at 10 Breweries", category: .Brewery, trophy: UIImage(named:  "BreweryTrophy"))
    static let cafeAward = Award(name: "Java Joe Award", caption: "Sip coffee at 10 Cafe's", category: .Cafe, trophy: UIImage(named:  "CafeTrophy"))
    static let activityAward = Award(name: "Adventurer Award", caption: "Enjoy 10 Activities", category: .Activity, trophy: UIImage(named:  "ActivityTrophy"))

    static let allAwards = [wineryAward, breweryAward, cafeAward, pizzeriaAward, activityAward]
    
}
