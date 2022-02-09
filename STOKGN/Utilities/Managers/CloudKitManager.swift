//
//  File.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-02-08.
//

import CloudKit


struct CloudKitManager {
    
    
    static func getLocations(completed: @escaping (Result<[OKGNLocation], Error>) -> Void) {
        let sortDescriptor = NSSortDescriptor(key: OKGNLocation.kName, ascending: true)
        let query = CKQuery(recordType: RecordType.location, predicate: NSPredicate(value: true))
        query.sortDescriptors = [sortDescriptor]
        
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { records, error in
            guard error == nil else {
                completed(.failure(error!))
                return
            }
            
            guard let records = records else { return }
            
            let locations = records.map { $0.convertToOKGNLocation() }
            completed(.success(locations))
            
        }
    }
}
