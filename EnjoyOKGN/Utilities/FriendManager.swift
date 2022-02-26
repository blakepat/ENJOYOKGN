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
        print("🥶 \(friendName)")
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
        
        
        //Also add reference to friend on adders account
        
    }
    
    //REFERENCE
//    func getUserReviews(for profileID: CKRecord.ID, completed: @escaping (Result<[OKGNReview], Error>) -> Void) {
//        let reference = CKRecord.Reference(recordID: profileID, action: .none)
//        let predicate = NSPredicate(format: "reviewer == %@", reference)
//        let query = CKQuery(recordType: "OKGNReview", predicate: predicate)
//
//        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { records, error in
//            guard let records = records, error == nil else {
//                completed(.failure(error!))
//                print(error!)
//                return
//            }
//
//            let reviews = records.map { $0.convertToOKGNReview() }
//            completed(.success(reviews))
//
//        }
//    }
    
}
