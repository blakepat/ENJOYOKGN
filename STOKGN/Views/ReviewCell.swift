//
//  ReviewCell.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-01-22.
//

import SwiftUI

struct ReviewCell: View {
    
    var user: User
    var location: Location
    var height: CGFloat
    
    var body: some View {
        
        ZStack {
            
            Color.white
            
            HStack(alignment: .top) {
                VStack(alignment: .leading) {

                    HStack {
                        Image(uiImage: user.photo)
                            .resizable()
                            .clipShape(Circle())
                            .frame(width: 50, height: 50)
                            .scaledToFit()
                        .font(.title)
                        
                        Text("\(user.name) visited")
                            .minimumScaleFactor(0.75)
                    }
                    
                    
                
    
                    Text("\(location.name)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)
                    
                    Spacer()
                    
                    Text("\"Three word review\"")
                }
                .padding()
                
                Spacer()
                
                ZStack(alignment: .trailing) {
                    
                    //Change to image. Which will default to locations image if user doesn't upload image with review
                    Image(uiImage: location.image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: height ,height: height)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("7.8")
                            .padding(12)
                            .background(Color.OKGNDarkYellow)
                            .clipShape(Capsule())
                            .padding()
                        
                        Spacer()
                        
                        
                    }
                }
                .frame(width: height)
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct ReviewCell_Previews: PreviewProvider {
    static var previews: some View {
        ReviewCell(user: MockData.mockUser, location: MockData.mockPizzeriaLocation, height: 180)
    }
}
