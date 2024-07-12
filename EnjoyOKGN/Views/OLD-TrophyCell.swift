//
//  TrophyCell.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-01-24.
//

import SwiftUI

struct TrophyCell: View {
    
    var review: OKGNReview
    
    
    var body: some View {
        ZStack {
            
            returnCategoryFromString(review.locationCategory).color
                
            
            HStack {
                VStack(spacing: 4) {
                    review.ranking?.trophyImage
                        .resizable()
                        .scaledToFit()
                    
                    Text("\(review.rating)")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    
                }
                .padding(12)
                
                VStack(alignment: .leading) {
                    
                    Text("Top \(review.locationCategory) Rating")
                        .foregroundColor(Color(white: 1, opacity: 0.6))
                        .font(.subheadline)
                    
                    Text("\(review.locationName)")
                        .foregroundColor(.white)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    
                    Text("\"\(review.reviewCaption)\"")
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.75)
                }
                
                Spacer()
                
                
                Image(uiImage: review.photo.convertToUIImage(in: .square))
                    .resizable()
                    .frame(width: 90, height: 90)
                    .scaledToFill()
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .frame(height: 120)
    }
    
}
//
//struct TrophyCell_Previews: PreviewProvider {
//    static var previews: some View {
//        TrophyCell(review: MockData.pizzeriaReview)
//    }
//}
