//
//  User.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-01-22.
//

import Foundation
import UIKit



struct User {
    
    var firstName: String
    var lastName: String
    var photo: UIImage?
    
    func createProfileImage() -> UIImage {
        guard let asset = photo else { return UIImage(named: "default-profileAvatar")! }
        return asset
    }
    
}
