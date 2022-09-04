//
//  DropDown.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-08-03.
//

import SwiftUI

struct DropDown: View {
    
    @State var expand = false
    @Binding var category: Category?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            HStack {
                Text(category?.description ?? "Champions")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Image(systemName: "chevron.down.circle")
                    .resizable()
                    .rotationEffect(Angle(degrees: expand ? 180 : 0))
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
            }
            .onTapGesture {
                withAnimation {
                    expand.toggle()
                }
                
            }
            
            //buttons inside
            if expand {
                Button {
                    withAnimation {
                        category = Category.Winery
                        expand.toggle()
                    }
                } label: {
                    Text("Wineries")
                        
                }.foregroundColor(.white)
                
                
                Button {
                    withAnimation {
                        category = Category.Brewery
                        expand.toggle()
                    }
                } label: {
                    Text("Breweries")
                      
                }.foregroundColor(.white)
                
                
                Button {
                    withAnimation {
                        category = Category.Pizzeria
                        expand.toggle()
                    }
                } label: {
                    Text("Pizzerias")
               
                }.foregroundColor(.white)
                
                Button {
                    withAnimation {
                        category = Category.Cafe
                        expand.toggle()
                    }
                } label: {
                    Text("Cafe's")
               
                }.foregroundColor(.white)
                
                Button {
                    withAnimation {
                        category = Category.Activity
                        expand.toggle()
                    }
                } label: {
                    Text("Activities")
               
                }.foregroundColor(.white)
            }
        
        }
        .padding(6)
        .background(LinearGradient(gradient: .init(colors: [Color.OKGNDarkYellow, category?.color ?? .yellow]), startPoint: .top, endPoint: .bottom))
        .cornerRadius(20)
        .animation(.spring(), value: true)
    }
}

struct DropDown_Previews: PreviewProvider {
    static var previews: some View {
        DropDown(category: .constant(Category.Activity))
    }
}
