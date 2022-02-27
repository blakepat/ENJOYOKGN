//
//  FriendManager.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-25.
//

import Foundation
import CloudKit

final class FriendManager: ObservableObject {
    
    @Published var friends: [OKGNProfile] = []
    
    func addFriend(friendName: String, completed: @escaping (Result<CKRecord, Error>) -> Void) {
        //Search for friend and add reference to adder on friends account
        let predicate = NSPredicate(format: "name == %@", friendName)
        let query = CKQuery(recordType: "OKGNProfile", predicate: predicate)
        
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { friendProfile, error in
            guard let friendProfile = friendProfile, error == nil else {
                completed(.failure(error!))
                print(error!)
                print("❌ Error searching for Friend Profile")
                return
            }
            
            completed(.success(friendProfile[0]))
        }
    }
    
    
    func acceptFriendRequest(profileReference: CKRecord.Reference, completed: @escaping (Result<[CKRecord], Error>) -> Void) {

        let predicate = NSPredicate(format: "friends CONTAINS %@", profileReference)
        let query = CKQuery(recordType: "OKGNProfile", predicate: predicate)
        
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { friendRequests, error in
            guard let friendRequests = friendRequests, error == nil else {
                completed(.failure(error!))
                print(error!)
                print("😭 Error retreiving friend REQUESTS")
                return
            }
            
            completed(.success(friendRequests))
        }
    }
    

    func getFriends(friendList: CKRecord.Reference, completed: @escaping (Result<[OKGNProfile], Error>) -> Void) {
        let predicate = NSPredicate(format: "friends CONTAINS %@", friendList)
        let query = CKQuery(recordType: "OKGNProfile", predicate: predicate)
        
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { friends, error in
            guard let friends = friends, error == nil else {
                completed(.failure(error!))
                print(error!)
                print("😭 Error querying friend list")
                return
            }
            
            completed(.success(friends.map({ $0.convertToOKGNProfile() })))
        }
        
        
    }
    
}
