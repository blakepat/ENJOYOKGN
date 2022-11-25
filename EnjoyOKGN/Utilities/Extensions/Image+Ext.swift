//
//  Image+Ext.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-08-03.
//

import SwiftUI


//struct categoryIconViewModifier: ViewModifier {
//
//    var isActive: Bool
//
//    func body(content: Content) -> some View {
//        content
//            .frame(width: 26, height: 26)
//            .scaledToFit()
//            .padding(8)
//            .offset(y: withAnimation(.linear(duration: 1)) { isActive ? -8 : 0 } )
//            .background(
//                Color.white
//                    .clipShape(Circle())
//                    .opacity(withAnimation(.linear(duration: 1)) { isActive ? 0.8 : 0.3 })
//                    .offset(y: withAnimation(.linear(duration: 1)) { isActive ? -8 : 0 } )
//            )
//            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 5, y: 5)
//            .animation(Animation.linear, value: isActive)
//            .scaleEffect(isActive ? 1.15 : 1)
//            .onTapGesture {
//                withAnimation(.linear) {
//                    isActive
//                    isActive
//                }
//            }
//    }
//
//
//
//
//}



extension Image {
    
    static let defaultProfileImage = Image("default-profileAvatar")
    
    
    func createIconView(isActive: Bool) -> some View {
        self
            .resizable()
            .frame(width: 26, height: 26)
            .scaledToFit()
            .padding(8)
            .offset(y: withAnimation(.linear(duration: 1)) { isActive ? -8 : 0 } )
            .background(
                Color.white
                    .clipShape(Circle())
                    .opacity(withAnimation(.linear(duration: 1)) { isActive ? 0.8 : 0.3 })
                    .offset(y: withAnimation(.linear(duration: 1)) { isActive ? -8 : 0 } )
            )
            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 5, y: 5)
            .animation(Animation.linear, value: isActive)
            .scaleEffect(isActive ? 1.15 : 1)

        
    }
}
