//
//  ProgressBar.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-01-22.
//

import SwiftUI

struct ProgressBar: View {
    
    @Environment(\.dynamicTypeSize) var typeSize
    var progress: Int
    var award: Award
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 8)
                    .opacity(0.3)
                    .foregroundColor(award.category.color)
                    .overlay(
                            Circle()
                                .stroke(Color.white.opacity(progress > 9 ? 0.3 : 0.0), lineWidth: 9)
                                .blur(radius: 5)
                                .blendMode(.overlay)
                    )
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(Float(self.progress) / 10, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                    .foregroundColor(award.category.color)
                    .rotationEffect(Angle(degrees: 270))
                    .animation(.linear, value: true)
                
                
                if progress >= 10 {
                    Image(uiImage: award.trophy)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .scaledToFit()
                        .shadow(color: Color.OKGNDarkYellow.opacity(0.3), radius: 10, x: 0, y: 0)
                } else {
                    Text(String(format: "%0.f/10%", min(Float(self.progress) / 10, 1.0) * 10.0))
                        .font(.footnote)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .padding(.top, 4)
                        .minimumScaleFactor(0.5)
                }
            }
            .frame(width: 70, height: 70)
            .padding(10)
            
            VStack {
                Text("\(award.name)")
                    .foregroundColor(.white)
                    
                Text("\(award.caption)")
                    .foregroundColor(.gray)
            }
            .font(.footnote)
            .minimumScaleFactor(0.5)
            .lineLimit(typeSize >= .accessibility1 ? 2 : 1)
        }
        .padding(.leading)

    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar(progress: 10, award: AwardTypes.pizzeriaAward)
    }
}
