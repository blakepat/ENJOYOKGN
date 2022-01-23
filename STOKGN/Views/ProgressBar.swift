//
//  ProgressBar.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-01-22.
//

import SwiftUI

struct ProgressBar: View {
    
    @Binding var progress: Float
    var award: Award
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.3)
                    .foregroundColor(award.color)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .foregroundColor(award.color)
                    .rotationEffect(Angle(degrees: 270))
                    .animation(.linear, value: true)
                
                //Eventually going to change this to Trophies for each award
                Text(String(format: "%0.f/10%", min(self.progress, 1.0) * 10.0))
                    .font(.body)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .padding(.top, 4)
                        
            }
            .frame(width: 90, height: 90)
            .padding(10)
            
            VStack {
                Text("\(award.name)")
                    .foregroundColor(.white)
                    .font(.footnote)
                    
                Text("\(award.caption)")
                    .foregroundColor(.gray)
                    .font(.footnote)
            }

        }
        .padding(.leading)

    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar(progress: .constant(10), award: AwardTypes.pizzaAward)
    }
}
