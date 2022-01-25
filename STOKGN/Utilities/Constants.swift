//
//  Constants.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-01-22.
//

import SwiftUI


enum Category {
    
    case Winery, Brewery, Cafe, Pizzeria, Activity
    
    var description : String {
      switch self {
      // Use Internationalization, as appropriate.
      case .Winery: return "Winery"
      case .Brewery: return "Brewery"
      case .Cafe: return "Cafe"
      case .Pizzeria: return "Pizzeria"
      case .Activity: return "Activity"
      }
    }
    
    var color: Color {
        switch self {
        // Use Internationalization, as appropriate.
        case .Winery: return Color.OKGNPurple
        case .Brewery: return Color.OKGNPeach
        case .Cafe: return Color.OKGNDarkYellow
        case .Pizzeria: return Color.OKGNPink
        case .Activity: return Color.OKGNLightYellow
        }
    }
    
//    static let pizzaAward = Award(name: "El Presidente Award", caption: "Eat at 10 Pizzerias", color: Color.OKGNPink)
//    static let wineryAward = Award(name: "Sommelier Award", caption: "Drink at 10 Wineries", color: Color.OKGNPurple)
//    static let breweryAward = Award(name: "Brewmaster Award", caption: "Drink at 10 Breweries", color: Color.OKGNPeach)
//    static let cafeAward = Award(name: "Java Joe Award", caption: "Visit 10 Cafe's", color: Color.OKGNDarkYellow)
//    static let activityAward = Award(name: "Adventurer Award", caption: "Complete 10 Activities", color: Color.OKGNLightYellow)
    
}

