//
//  Int+Ext.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-09-19.
//

import Foundation


extension String {
    func returnRanking() -> Ranking? {
        switch self {
        case "0":
            return nil
        case "1":
            return .first
        case "2":
            return .second
        case "3":
            return .third
        default:
            return nil
        }
    }
}
