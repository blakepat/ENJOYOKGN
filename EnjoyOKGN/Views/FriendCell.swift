//
//  FriendCell.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-25.
//

import SwiftUI

struct FriendCell: View {
    
    var profile: OKGNProfile
    
    @State var wineryCount: Int = 0
    @State var breweryCount: Int = 0
    @State var cafeCount: Int = 0
    @State var pizzeriaCount: Int = 0
    @State var activityCount: Int = 0
    
    @State var userReviews: [OKGNReview]
    
    var body: some View {
        
        ZStack {
            Color.OKGNDarkYellow
            
            HStack {
                ZStack {
                    Color.OKGNDarkYellow.luminanceToAlpha()
                        .clipShape(Circle())
                        .frame(width: 80)
                        .blur(radius: 15)
                    
                    Image(uiImage: profile.avatar.convertToUIImage(in: .square))
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 70, height: 70)
                        .scaledToFit()
                        .font(.title)
                }
   
                VStack(alignment: .leading, spacing: 0) {
                    Text(profile.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    HStack {
                        if wineryCount >= 10 {
                            Image(uiImage: AwardTypes.wineryAward.trophy)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .scaledToFill()
                        }
                        if breweryCount >= 10 {
                            Image(uiImage: AwardTypes.breweryAward.trophy)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .scaledToFill()
                        }
                        if cafeCount >= 10 {
                            Image(uiImage: AwardTypes.cafeAward.trophy)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .scaledToFill()
                        }
                        if pizzeriaCount >= 10 {
                            Image(uiImage: AwardTypes.pizzeriaAward.trophy)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .scaledToFill()
                        }
                        if activityCount >= 10 {
                            Image(uiImage: AwardTypes.activityAward.trophy)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .scaledToFill()
                        }
                    }
                }
  
                Spacer()
       
            }
        }
        .frame(height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear {
            wineryCount = userReviews.filter({returnCategoryFromString($0.locationCategory) == .Winery}).count
            breweryCount = userReviews.filter({returnCategoryFromString($0.locationCategory) == .Brewery}).count
            cafeCount = userReviews.filter({returnCategoryFromString($0.locationCategory) == .Cafe}).count
            pizzeriaCount = userReviews.filter({returnCategoryFromString($0.locationCategory) == .Pizzeria}).count
            activityCount = userReviews.filter({returnCategoryFromString($0.locationCategory) == .Activity}).count
        }
    }
}

//struct FriendCell_Previews: PreviewProvider {
//    static var previews: some View {
//        FriendCell(profile: MockData.mockUser.convertToOKGNProfile())
//    }
//}
