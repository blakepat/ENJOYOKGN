//
//  VenuesVisitedView.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-10-10.
//

import SwiftUI


struct VenuesVisitedView: View {
    
    @Binding var showVenuesVisitedSubCategories: Bool
    
    var pizzeriaCount: Int
    var wineryCount: Int
    var breweryCount: Int
    var cafeCount: Int
    var activityCount: Int
    
    var body: some View {
        
        VStack(alignment: .trailing, spacing: 0) {
            Text("Venues Visited: \(wineryCount + breweryCount + pizzeriaCount + cafeCount + activityCount)")
                .fontWeight(.bold)
                .padding(8)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .background(showVenuesVisitedSubCategories ? .OKGNDarkYellow : Color.OKGNDarkBlue)
                .foregroundColor(showVenuesVisitedSubCategories ? .black : .white)
                .clipShape(Capsule())
                .contentShape(Capsule())
                .overlay(Capsule().stroke(Color.OKGNDarkYellow, lineWidth: 2))
                .onTapGesture {
                    withAnimation {
                        showVenuesVisitedSubCategories.toggle()
                    }
                }
                .zIndex(1)

            VStack(alignment: .trailing, spacing: 6) {
                Text("Wineries: \(wineryCount)").fontWeight(.semibold)
                Text("Breweies: \(breweryCount)").fontWeight(.semibold)
                Text("Pizzarias: \(pizzeriaCount)").fontWeight(.semibold)
                Text("Cafe's: \(cafeCount)").fontWeight(.semibold)
                Text("Activities: \(activityCount)").fontWeight(.semibold)
            }
            .foregroundColor(.black)
            .frame(height: showVenuesVisitedSubCategories ? 120 : 0)
            .padding(.top, showVenuesVisitedSubCategories ? 28 : 0)
            .padding(4)
            .padding(.bottom, 4)
            .padding(.trailing, 6)
            .background(Color.OKGNDarkYellow)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .offset(y: -22)
            .zIndex(0)
        }
    }
}

