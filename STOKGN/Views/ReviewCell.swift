//
//  ReviewCell.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-01-22.
//

import SwiftUI

struct ReviewCell: View {
    
    var review: Review
    
    var body: some View {
        
        ZStack {
            
            review.location.category.color
            
            HStack(alignment: .top) {
                VStack(alignment: .leading) {

                    HStack {
                        Image(uiImage: review.reviewer.createProfileImage())
                            .resizable()
                            .clipShape(Circle())
                            .frame(width: 70, height: 70)
                            .scaledToFit()
                            .font(.title)
                        
                        Spacer()
                        
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 16).stroke(lineWidth: 6)
                                .foregroundColor(.OKGNDarkYellow)
                            
                            VStack(spacing: 0) {
                                if let trophy = review.ranking?.trophyImage {
                                    trophy
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 30)
                                        
                                }
                                Text(review.rating)
                                    .font(.title2)
//                                    .foregroundColor(.white)
                            }
                            
                        }
                        .frame(width: 70, height: 70)
                        

                        
                        
                    }
                    
            
    
                    Text("\(review.location.name)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)
                    
                    Text("\"" + review.reviewCaption + "\"")
                        .minimumScaleFactor(0.75)
                    
                    Text("\(review.date, formatter: DateFormatter.shortDate)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .minimumScaleFactor(0.75)
                        
                }
                .padding(.top)
                .padding(.horizontal)
                
                Spacer()
                
                Image(uiImage: review.location.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 160 ,height: 160)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 16))

            }
        }
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct ReviewCell_Previews: PreviewProvider {
    static var previews: some View {
        ReviewCell(review: MockData.pizzeriaReview)
    }
}
