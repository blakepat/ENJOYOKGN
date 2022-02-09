//
//  CKRecord+Ext.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-02-08.
//

import CloudKit


extension CKRecord {
    
    func convertToOKGNLocation()-> OKGNLocation { OKGNLocation(record: self) }
    
    func convertToOKGNProfile()-> OKGNProfile { OKGNProfile(record: self) }
    
}
