//
//  OKGNProfile.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-02-07.
//

import CloudKit
import SwiftUI


struct OKGNProfile: Identifiable {
    
    static let kName = "name"
    static let kAvatar = "avatar"
    static let kFriends = "friendList"
    static let kRequests = "requestList"
    static let kFollowers = "followerList"
    static let kDeleteList = "deleteList"
    static let kFavouriteLocations = "favouriteLocations"
    static let kAwards = "awards"
    static let kBlockList = "blockList"
    
    let id: CKRecord.ID
    let name: String
    let avatar: CKAsset!
    @State var friends: [CKRecord.Reference]
    @State var requests: [CKRecord.Reference]
    @State var followers: [CKRecord.Reference]
    @State var deleteList: [CKRecord.Reference]
    @State var favouriteLocations: [CKRecord.Reference]
    @State var awards: [String]
    @State var blockList: [CKRecord.Reference]

    
    init(record: CKRecord) {
        id  = record.recordID
        name   = record[OKGNProfile.kName] as? String ?? "N/A"
        avatar = record[OKGNProfile.kAvatar] as? CKAsset
        friends = record[OKGNProfile.kFriends] as? [CKRecord.Reference] ?? []
        requests = record[OKGNProfile.kRequests] as? [CKRecord.Reference] ?? []
        followers = record[OKGNProfile.kFollowers] as? [CKRecord.Reference] ?? []
        deleteList = record[OKGNProfile.kDeleteList] as? [CKRecord.Reference] ?? []
        favouriteLocations = record[OKGNProfile.kFavouriteLocations] as? [CKRecord.Reference] ?? []
        awards = record[OKGNProfile.kAwards] as? [String] ?? []
        blockList = record[OKGNProfile.kBlockList] as? [CKRecord.Reference] ?? []
    }
    
    
    func createProfileImage() -> UIImage {
        guard let asset = avatar else { return UIImage(named: "default-profileAvatar")! }
        return asset.convertToUIImage(in: .square)
    }
}
