//
//  Constants.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-01-22.
//

import SwiftUI

let categories: [Category] = [.Winery, .Brewery, .Cafe, .Pizzeria, .Activity]

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
        case .Cafe: return Color.OKGNLightBlue
        case .Pizzeria: return Color.OKGNPink
        case .Activity: return Color.OKGNLightGreen
        }
    }
}

func returnCategoryFromString(_ name: String) -> Category {
    switch name {
    // Use Internationalization, as appropriate.
    case "Winery": return .Winery
    case "Brewery": return .Brewery
    case "Cafe": return .Cafe
    case "Pizzeria": return .Pizzeria
    case "Activity": return .Activity
    default:
        return .Activity
    }
}


enum Ranking {
    
    case first, second, third
    
    var trophyImage : Image {
        switch self {
        case .first: return Image("GoldTrophy")
        case .second: return Image("SilverTrophy")
        case .third: return Image("BronzeTrophy")
        }
    }
    
}


enum RecordType {
    static let location = "OKGNLocation"
    static let profile = "OKGNProfile"
}


// To-do: Change these default images (something more bland and small in storage size
enum PlaceholderImage {
    static let avatar = UIImage(named: "default-profileAvatar")!
    static let square = UIImage(named: "MockReviewPhoto")!
    static let banner = UIImage(named: "MockLocationPhoto")!
}


enum ImageDimension {
    case square, banner
    
    static func getPlaceholder(for dimension: ImageDimension) -> UIImage {
        switch dimension {
        case .square:
            return PlaceholderImage.square
        case .banner:
            return PlaceholderImage.banner
        }
    }
}
