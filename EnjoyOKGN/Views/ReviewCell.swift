//
//  ReviewCell.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-01-22.
//

import SwiftUI

struct ReviewCell: View {
    
    @Environment(\.dynamicTypeSize) var typeSize
    var review: OKGNReview
    var showTrophy: Bool
    var height: CGFloat
    
    
    var body: some View {
        
        ZStack {
            
            VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
                .background(LinearGradient(gradient: Gradient(colors: [returnCategoryFromString(review.locationCategory).color, .black]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .opacity(0.5)
            
            
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {

                    HStack {
                        ZStack {
                            returnCategoryFromString(review.locationCategory).color
                                .clipShape(Circle())
                                .frame(width: 50)
                                .blur(radius: 15)
                            
                            if let avatar = review.reviewerAvatar?.convertToUIImage(in: .square) {
                                Image(uiImage: avatar)
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 40, height: 40)
                                    .scaledToFit()
                            }
                        }
                    
                        VStack(spacing: 0) {
                            if let trophy = review.ranking?.trophyImage, showTrophy {
                                trophy
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 16)

                            }
                            Text(review.rating)
                                .font(.subheadline)
                                .minimumScaleFactor(0.7)
                        }
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 16).stroke(lineWidth: 2)
                                .foregroundColor(.OKGNDarkYellow)
                        )
                        
                        Spacer()
                    }
                    .padding(.top, 4)
            
    
                    Text("\(review.locationName)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(4)
                        .minimumScaleFactor(0.7)
                        .allowsTightening(true)
                    
                    Text("\"" + review.reviewCaption + "\"")
                        .font(.footnote)
                        .minimumScaleFactor(0.7)
                        .lineLimit(4)
                    
                    HStack {
                        Text(review.reviewerName)
                            .font(.caption)
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.7)
                        
                        Spacer()
                        
                        Text("\(review.date, formatter: DateFormatter.shortDate)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.7)
                    }
                        
                }
                .padding(.top, 4)
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                Spacer()
                
                Image(uiImage: review.photo.convertToUIImage(in: .square))
                    .resizable()
                    .scaledToFill()
                    .frame(width: height, height: height)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 16))

            }
        }
        .frame(minHeight: typeSize >= .xxLarge ? height : nil, maxHeight: typeSize >= .xxLarge ? nil : height)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
//
//struct ReviewCell_Previews: PreviewProvider {
//    static var previews: some View {
//        ReviewCell(review: MockData.pizzeriaReview)
//    }
//}
