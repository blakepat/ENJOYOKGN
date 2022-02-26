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
   
                VStack {
                    Text(profile.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    HStack {
                        //Add trophies here eventually
                    }
                }
  
                Spacer()
       
            }
        }
        .frame(height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct FriendCell_Previews: PreviewProvider {
    static var previews: some View {
        FriendCell(profile: MockData.mockUser.convertToOKGNProfile())
    }
}
