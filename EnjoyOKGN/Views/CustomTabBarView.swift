//
//  CustomTabBarView.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-11-04.
//

import SwiftUI

struct CustomTabBarView: View {
    
    let tabs: [TabBarItem]
    @Binding var selection: TabBarItem
    @Namespace private var namespace
    
    var body: some View {
        tabBar
    }
}

struct CustomTabBarView_Previews: PreviewProvider {
    
    static let tabs: [TabBarItem] = [.home, .feed, .create, .map, .list]
    
    static var previews: some View {
        CustomTabBarView(tabs: tabs, selection: .constant(tabs.first!))
    }
}


extension CustomTabBarView {
    
    
    private func switchToTab(tab: TabBarItem) {
        withAnimation {
            selection = tab
        }
        
    }
    
    
    private func tabView(tab: TabBarItem) -> some View {
        VStack {
            Image(systemName: tab.iconName)
                .font(.subheadline)
            
            Text(tab.title)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
        }
        .foregroundColor(selection == tab ? tab.color : Color.gray)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            withAnimation {
                ZStack {
                    if selection == tab {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(tab.color.opacity(0.2))
                            .matchedGeometryEffect(id: "backgroundRectangle", in: namespace)
                    }
                }
            }
        )
    }
    
    
    private var tabBar: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                tabView(tab: tab)
                    .onTapGesture {
                        switchToTab(tab: tab)
                    }
            }
        }
        .padding(.horizontal, 6)
        .background(Color.white.ignoresSafeArea(edges: .bottom))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
}
