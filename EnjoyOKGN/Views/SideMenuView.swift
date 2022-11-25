//
//  SideMenuView.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-22.
//

import SwiftUI

struct SideMenuView: View {
    
    @Binding var categoryFilter: Category?
    @Binding var menuOpen: Bool
    
    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark)).opacity(0.5)
                .edgesIgnoringSafeArea(.top)
                .opacity(self.menuOpen ? 1 : 0)
                .animation(Animation.easeIn.delay(0.15), value: menuOpen)
                .onTapGesture {
                    menuOpen = false
                }
            
            GeometryReader { geo in
                HStack {
                    VStack {
                        List {
                            ForEach(categories, id: \.self) { category in
                                HStack {
                                    Circle().frame(width: 10).foregroundColor(category.color)
                                    Text(category.description)
                                        .foregroundColor(.white)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .onTapGesture {
                                    categoryFilter = nil
                                    categoryFilter = category
                                    menuOpen = false
                                }
                            }
                            .listRowBackground(Color.clear)
                            HStack {
                                Circle().frame(width: 10).foregroundColor(.OKGNDarkYellow)
                                Text("Clear filter")
                                    .foregroundColor(.white)
                                    .bold()
                            }
                            .listRowBackground(Color.clear)
                            .onTapGesture {
                                categoryFilter = nil
                                menuOpen = false
                                
                            }
                        }
                        .padding(.top)
                        .listStyle(.sidebar)
                    }
                    .background(VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark)))
                    .frame(width: 200)
                    .offset(x: menuOpen ? 0 : -400, y: -geo.safeAreaInsets.bottom / 200)
                    .animation(.easeInOut, value: menuOpen)
                    .edgesIgnoringSafeArea(.vertical)
                    
                    Spacer()
                }
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView(categoryFilter: .constant(.Activity), menuOpen: .constant(true))
    }
}
