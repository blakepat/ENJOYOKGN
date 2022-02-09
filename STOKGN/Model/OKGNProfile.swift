//
//  OKGNProfile.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-02-07.
//

import CloudKit
import SwiftUI


struct OKGNProfile {
    
    static let kFirstName = "firstName"
    static let kLastName = "lastName"
    static let kAvatar = "avatar"
    static let kBio = "bio"
    
    let ckRecordID: CKRecord.ID
    let firstName: String
    let lastName: String
    let avatar: CKAsset!
    let bio: String

    
    init(record: CKRecord) {
        ckRecordID  = record.recordID
        firstName   = record[OKGNProfile.kFirstName] as? String ?? "N/A"
        lastName = record[OKGNProfile.kLastName] as? String ?? "N/A"
        avatar = record[OKGNProfile.kAvatar] as? CKAsset
        bio     = record[OKGNProfile.kBio] as? String ?? "N/A"
    }
    
    
//    func createProfileImage() -> UIImage {
//        guard let asset = avatar else { return UIImage(named: "default-profileAvatar")! }
//        return asset
//    }
}
