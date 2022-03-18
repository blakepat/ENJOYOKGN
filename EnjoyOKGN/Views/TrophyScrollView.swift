//
//  TrophyScrollView.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-03-17.
//

import SwiftUI


struct TrophyScrollView: View {
    
    let rows: [GridItem] = Array(repeating: .init(.flexible()), count: 1)
    
    var pizzeriaCount: Int
    var wineryCount: Int
    var breweryCount: Int
    var cafeCount: Int
    var activityCount: Int
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: rows) {
                ProgressBar(progress: wineryCount, award: AwardTypes.wineryAward)
                ProgressBar(progress: breweryCount, award: AwardTypes.breweryAward)
                ProgressBar(progress: pizzeriaCount, award: AwardTypes.pizzeriaAward)
                ProgressBar(progress: cafeCount, award: AwardTypes.cafeAward)
                ProgressBar(progress: activityCount, award: AwardTypes.activityAward)
            }
        }
        .frame(height: 200)
    }
}
