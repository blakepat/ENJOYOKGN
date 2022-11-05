//
//  TrophyScrollView.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-03-17.
//

import SwiftUI


struct TrophyScrollView: View {
    
    let rows: [GridItem] = Array(repeating: .init(.flexible()), count: 1)
    var categoryVisitCounts: [Int]
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: rows) {
                
                ForEach(0..<5) { i in
                    ProgressBar(progress: categoryVisitCounts[i], award: AwardTypes.allAwards[i])
                }
            }
        }
        .frame(height: 140)
    }
}
