//
//  Text+Ext.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-11-11.
//

import SwiftUI


struct noVisitBanner: ViewModifier {
    
    let backgroundColor: Color
    let minX: Double
    
    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(.center)
            .padding(8)
            .font(.title2)
            .foregroundColor(.black)
            .background(
                backgroundColor
                    .opacity(0.4)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            )
            .frame(width: 300, height: 100)
            .offset(y: 40)
            .rotation3DEffect(.degrees(minX / -10), axis: (x: 0, y: 1, z: 0))
    }
}



extension Text {
    
    func createNoVisitsBanner(minX: Double, color: Color) -> some View {
        modifier(noVisitBanner(backgroundColor: color, minX: minX))
    }
}
