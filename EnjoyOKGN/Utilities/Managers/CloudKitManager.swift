//
//  File.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-02-08.
//

import CloudKit
import SwiftUI


final class CloudKitManager: ObservableObject {
    
    static let shared = CloudKitManager()
    
    private init() {}
    
    @Published var userRecord: CKRecord? {
        didSet { print("0️⃣ userRecord set!") }
    }
    @Published var profileRecordID: CKRecord.ID? {
        didSet {
            print("6️⃣ profileRecordID set!")
        }
    }
    @Published var profile: CKRecord? {
        didSet {
            print("7️⃣ proile CKRecord set")
        }
    }
    let container = CKContainer.default()

    
//    // Base functions
//    func getUserRecord() {
//        CKContainer.default().fetchUserRecordID { recordID, error in
//            guard let recordID = recordID, error == nil else {
//                print(error!.localizedDescription)
//                return
//            }
//
//            //Get UserRecordID from the container
//            CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { userRecord, error in
//                guard let userRecord = userRecord, error == nil else {
//                    print(error!.localizedDescription)
//                    return
//                }
//                DispatchQueue.main.async {
//                    self.userRecord = userRecord
//                }
//
//                if let profileReference = userRecord["userProfile"] as? CKRecord.Reference {
//                    DispatchQueue.main.async {
//                        self.profileRecordID = profileReference.recordID
//                    }
//                }
//            }
//        }
//    }
    
    
    // Base functions
    func getUserRecord() async throws {
        print("AAA - getUserRecord Called")
        do {
            let recordID = try await container.userRecordID()
            let record = try await container.publicCloudDatabase.record(for: recordID)
             
            DispatchQueue.main.async {
                self.userRecord = record
            }

            if let profileReference = record["userProfile"] as? CKRecord.Reference {
                self.profileRecordID = profileReference.recordID
            }
        } catch {
            print("❌ unable to get userRecord!")
        }
        
    }
    
    func getFriendUserRecord(id: CKRecord.ID, completed: @escaping () -> () ) async throws -> CKRecord? {
        print("BBB - getFriendUserRecord Called")
        do {
            return try await container.publicCloudDatabase.record(for: id)
        } catch let err {
            print("👺 \(err)")
            return nil
        }
    }
    
    
    func getLocations(completed: @escaping (_ loader: Bool) -> Void) async throws -> [OKGNLocation] {
        print("CCC - getLocations Called")
        let query = CKQuery(recordType: RecordType.location, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: OKGNLocation.kName, ascending: true)]
        
        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap { _, result in try? result.get() }
        
        completed(false)
        
        return records.map { $0.convertToOKGNLocation() }
        
    }
    
    
    func getLocationNames(completed: @escaping (_ loader: Bool) -> Void) async throws -> [(CKRecord.ID, String, String)] {
        print("DDD - getLocationNames Called")
        let query = CKQuery(recordType: RecordType.location, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: OKGNLocation.kName, ascending: true)]
        
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["recordName", "name", "category"]
        
        
        
        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        return matchResults.compactMap { _, result in
            guard let record = try? result.get(),
                  let locationName = record["name"] as? String,
                  let category = record["category"] as? String
            else { print("🤢"); return nil }
                
            completed(false)
            return (record.recordID, locationName, category)
        }
        
        

    }

    //************************************************************
    //Friends/Followers Functions

    func getFriendRecord(friendName: String) async throws -> CKRecord {
        print("EEE - getFriendRecord Called")
        let predicate = NSPredicate(format: "name == %@", friendName)
        let query = CKQuery(recordType: "OKGNProfile", predicate: predicate)
        
        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let friendRecord = matchResults.compactMap { _, result in try? result.get() }
        
        return friendRecord.first ?? CKRecord.init(recordType: RecordType.profile)
    }
    
    
    func getFollowRequests(for profileReference: CKRecord.Reference) async throws -> [CKRecord] {
        print("FFF - getFollowRequests Called")
        let predicate = NSPredicate(format: "requestList CONTAINS %@", profileReference)
        let query = CKQuery(recordType: "OKGNProfile", predicate: predicate)
        
        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        
        return matchResults.compactMap { _, result in try? result.get() }
    }
    
    
    func getFriends(for profileReference: CKRecord.Reference) async throws -> [CKRecord] {
        print("GGG - getFriends Called")
        let predicate = NSPredicate(format: "friendList CONTAINS %@", profileReference)
        let query = CKQuery(recordType: "OKGNProfile", predicate: predicate)
        
        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        
        return matchResults.compactMap { _, result in try? result.get() }
    }
    
    
    func getUsers(for profile: CKRecord, passedCursor: CKQueryOperation.Cursor?) async throws -> ([OKGNProfile], CKQueryOperation.Cursor?) {
        print("HHH - getUsers Called")
        
        let profileReference = CKRecord.Reference.init(recordID: profile.recordID, action: .none)
        
        let friendPredicate = NSPredicate(format: "NOT (friendList CONTAINS %@)", profileReference)
        let selfPredicate = NSPredicate(format: "name != %@", profile.convertToOKGNProfile().name)
        let predicates = NSCompoundPredicate(type: .and, subpredicates: [friendPredicate, selfPredicate])
        
        let query = CKQuery(recordType: "OKGNProfile", predicate: predicates)
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        if passedCursor == nil {
            let (matchedResults, cursor) = try await container.publicCloudDatabase.records(matching: query, resultsLimit: 10)
            let users = matchedResults.compactMap { _, result in try? result.get() }
            let usersToReturn = users.map { $0.convertToOKGNProfile() }

            return (usersToReturn, cursor)
            
        } else if let cursor = passedCursor {
            let (moreMatchedResults, newCursor) = try await self.container.publicCloudDatabase.records(continuingMatchFrom: cursor, resultsLimit: 20)
            let users = moreMatchedResults.compactMap { _, result in try? result.get() }
            let usersToReturn = users.map { $0.convertToOKGNProfile() }
            
            return (usersToReturn, newCursor)
        }
        
        return ([], nil)

    }
    
    
    func getUsersToRemove(for profileReference: CKRecord.Reference) async throws -> [CKRecord] {
        print("III - getUsersToRemove Called")
        let predicate = NSPredicate(format: "deleteList CONTAINS %@", profileReference)
        let query = CKQuery(recordType: "OKGNProfile", predicate: predicate)
        
        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        
        return matchResults.compactMap { _, result in try? result.get() }
        
    }
    
    
    //************************************************************
    //Review Functions
    
    func getFriendsReviews(for friendList: [CKRecord.Reference], passedCursor: CKQueryOperation.Cursor?, sortBy: String) async throws -> ([OKGNReview], CKQueryOperation.Cursor?) {
        
        print("JJJ - getFriendsReviews Called")
        if friendList.isEmpty { return ([], nil) }
        
        let predicate = NSPredicate(format: "reviewer IN %@", friendList)
        let query = CKQuery(recordType: "OKGNReview", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: sortBy, ascending: false)]
        
        if passedCursor == nil {
            
            print("✅✅ non-cursor called")
            
            let (matchedResults, cursor) = try await self.container.publicCloudDatabase.records(matching: query, resultsLimit: 12)
            let reviews = matchedResults.compactMap { _, result in try? result.get() }
            let reviewsToReturn = reviews.map { $0.convertToOKGNReview() }
            return (reviewsToReturn, cursor)
        } else {
            if let cursor = passedCursor {
                
                print("✅✅✅ Cursor called")
                
                let (moreMatchedResults, newCursor) = try await self.container.publicCloudDatabase.records(continuingMatchFrom: cursor, resultsLimit: 1)
                let reviews = moreMatchedResults.compactMap { _, result in try? result.get() }
                let reviewsToReturn = reviews.map { $0.convertToOKGNReview() }
                
                return (reviewsToReturn, newCursor)
            }
        }
        
        return ([], nil)
    }
    
    
    
    
    func getOneLocationFriendsReviews(for friendList: [CKRecord.Reference], location: String, passedCursor: CKQueryOperation.Cursor?) async throws -> ([OKGNReview], CKQueryOperation.Cursor?) {
        
        print("KKK - getOneLocationFriendReviews Called")
        
        if friendList.isEmpty { return ([], nil) }
        
        let friendsPredicate = NSPredicate(format: "reviewer IN %@", friendList)
        let locationPredicate = NSPredicate(format: "locationName == %@", location)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [friendsPredicate, locationPredicate])
        
        let query = CKQuery(recordType: "OKGNReview", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        if passedCursor == nil {
            let (matchedResults, cursor) = try await container.publicCloudDatabase.records(matching: query)
            let reviews = matchedResults.compactMap { _, result in try? result.get() }
            let reviewsToReturn = reviews.map { $0.convertToOKGNReview() }
            return (reviewsToReturn, cursor)
            
        } else if let cursor = passedCursor {
            let (moreMatchedResults, newCursor) = try await self.container.publicCloudDatabase.records(continuingMatchFrom: cursor, resultsLimit: 1)
            let reviews = moreMatchedResults.compactMap { _, result in try? result.get() }
            let reviewsToReturn = reviews.map { $0.convertToOKGNReview() }
            
            return (reviewsToReturn, newCursor)
        }
        
        return ([], nil)

    }
    
    
    
    func getUserReviews(for profileID: CKRecord.ID) async throws -> [OKGNReview] {
        print("🧑🏿‍🎤LLL - getUserReviews Called")
        let reference = CKRecord.Reference(recordID: profileID, action: .none)
        let predicate = NSPredicate(format: "reviewer == %@", reference)
        let query = CKQuery(recordType: "OKGNReview", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "rating", ascending: false)]
        
        let (matchedResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let reviews = matchedResults.compactMap { _, result in try? result.get() }
        return reviews.map { $0.convertToOKGNReview() }
    }
    

    
    func getOneLocationUserReviews(for profileID: CKRecord.ID, location: String) async throws -> [OKGNReview] {
        print("MMM - getONELocationReviews Called")
        //print(location)
        
        let reference = CKRecord.Reference(recordID: profileID, action: .none)
        let userPredicate = NSPredicate(format: "reviewer == %@", reference)
        let locationPredicate = NSPredicate(format: "locationName == %@", location)
        let predicates = NSCompoundPredicate(type: .and, subpredicates: [userPredicate, locationPredicate])
        
        let query = CKQuery(recordType: "OKGNReview", predicate: predicates)
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        let (matchedResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let reviews = matchedResults.compactMap { _, result in try? result.get() }
        return reviews.map { $0.convertToOKGNReview() }
    }
    
    
    
    
    func getUserReviewsForProfileUpdate(for profileID: CKRecord.ID) async throws -> [CKRecord] {
        print("NNN - getUserReviewsForProfileUpdate Called")
        let reference = CKRecord.Reference(recordID: profileID, action: .none)
        let predicate = NSPredicate(format: "reviewer == %@", reference)
        let query = CKQuery(recordType: "OKGNReview", predicate: predicate)
        
        let (matchedResults, _) = try await container.publicCloudDatabase.records(matching: query)
        return matchedResults.compactMap { _, result in try? result.get() }
        
    }
    
    
    //************************************************************
    // General Functions
    func batchSave(records: [CKRecord]) async throws -> [CKRecord]? {
        print("OOO - batchSave Called")
        let (savedResults, _) = try await container.publicCloudDatabase.modifyRecords(saving: records, deleting: [])
        do {
            return try savedResults.compactMap {_, result in try result.get() }
        } catch {
            print("⚠️ save failed")
            return nil
        }
    }
    
    
    func save(record: CKRecord) async throws -> CKRecord {
        print("PPP - save Called")
        return try await container.publicCloudDatabase.save(record)
    }

    
    func fetchRecord(with id: CKRecord.ID) async throws -> CKRecord {
        print("QQQ - fetchRecord Called")
        return try await container.publicCloudDatabase.record(for: id)
    }
    
    
    func deleteRecord(recordID: CKRecord.ID) async throws -> CKRecord.ID {
        print("OOO - deleteRecord Called")
        return try await container.publicCloudDatabase.deleteRecord(withID: recordID)
    }
}
