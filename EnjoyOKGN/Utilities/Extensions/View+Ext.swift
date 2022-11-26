//
//  View+Ext.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-03-18.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
    
    func embedInScrollView() -> some View {
        GeometryReader { geo in
            ScrollView {
                frame(minHeight: geo.size.height, maxHeight: .infinity)
            }
        }
    }
}
