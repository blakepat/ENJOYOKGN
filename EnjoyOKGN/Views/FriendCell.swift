//
//  FriendCell.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-25.
//

import SwiftUI

struct FriendCell: View {
    
    var profile: OKGNProfile
    
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
                        ForEach(profile.awards, id: \.self) { categoryString in
                            ZStack {
                                
                                let category = returnCategoryFromString(categoryString)
                                
                                Circle()
                                    .stroke(category.color, lineWidth: 4)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .foregroundColor(category.color.opacity(0.4))
                                    )
                                
                                category.trophyImage
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                            
                        
                        }
                    }
                    .padding(4)
                }
  
                Spacer()
       
            }
        }
        .frame(height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

//struct FriendCell_Previews: PreviewProvider {
//    static var previews: some View {
//        FriendCell(profile: MockData.mockUser.convertToOKGNProfile())
//    }
//}
