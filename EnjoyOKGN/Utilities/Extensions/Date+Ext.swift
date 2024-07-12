//
//  Date+Ext.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-01-26.
//

import Foundation


extension DateFormatter {
    
    static let shortDate: DateFormatter = {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, MMM d"
    
        return dateFormatter
    }()
    
    
}
