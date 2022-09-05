//
//  EmailAddLocation.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-09-04.
//

import Foundation
import SwiftUI


struct EmailAddLocation {
    
    let toAddress: String
    let subject: String
    let messageHeader: String
    var body: String { "\(messageHeader)" }
    
    
    func send(openURL: OpenURLAction) {
        let urlString = "mailto:\(toAddress)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")"
     
        guard let url = URL(string: urlString) else { return }
        openURL(url) { accepted in
            if !accepted {
                print("This device does not support email \(body)")
            }
        }
        
    }
    
    
    
}
