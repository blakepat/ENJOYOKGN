//
//  VenuesVisitedView.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-10-10.
//

import SwiftUI


struct VenuesVisitedView: View {
    
    @Binding var showVenuesVisitedSubCategories: Bool
    
//    var pizzeriaCount: Int
//    var wineryCount: Int
//    var breweryCount: Int
//    var cafeCount: Int
//    var activityCount: Int
    
    var allCategoriesVisitCount: [Int]
    
    var body: some View {
        
        VStack(alignment: .trailing, spacing: 0) {
            Text("Venues Visited: \(allCategoriesVisitCount.reduce(0, +))")
                .fontWeight(.bold)
                .padding(8)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
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
                Text("Wineries: \(allCategoriesVisitCount[0])").fontWeight(.semibold)
                Text("Breweries: \(allCategoriesVisitCount[1])").fontWeight(.semibold)
                Text("Cafe's: \(allCategoriesVisitCount[2])").fontWeight(.semibold)
                Text("Pizzaria's: \(allCategoriesVisitCount[3])").fontWeight(.semibold)
                Text("Activities: \(allCategoriesVisitCount[4])").fontWeight(.semibold)
            }
            .foregroundColor(.black)
            .frame(height: showVenuesVisitedSubCategories ? nil : 0)
            .padding(.top, showVenuesVisitedSubCategories ? 28 : 0)
            .padding(4)
            .lineLimit(1)
            .padding(.bottom, 4)
            .padding(.trailing, 6)
            .background(Color.OKGNDarkYellow)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .offset(y: -22)
            .zIndex(0)
            .minimumScaleFactor(0.5)
        }
    }
}

