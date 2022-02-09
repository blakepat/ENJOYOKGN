//
//  Review.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-01-24.
//

import Foundation
import UIKit


struct Review: Identifiable {
    
    let id = UUID()
    var location: Location
    var reviewer: User
    var reviewCaption: String
    var photo: UIImage
    var rating: String
    var ranking: Ranking?
    var date: Date
    
}
