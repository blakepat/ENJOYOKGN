//
//  XDismissButton.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-02-03.
//

import SwiftUI

import SwiftUI

struct XDismissButton: View {
    
    var color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 30, height: 30)
                .foregroundColor(color)
            
            Image(systemName: "xmark")
                .foregroundColor(.white)
                .imageScale(.small)
                .frame(width: 44, height: 44)
        }
    }
}

struct XDismissButton_Previews: PreviewProvider {
    static var previews: some View {
        XDismissButton(color: .OKGNDarkYellow)
    }
}
