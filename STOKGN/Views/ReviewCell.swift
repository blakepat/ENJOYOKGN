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
    
    var body: some View {
        
        ZStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {

                    Image(uiImage: user.photo)
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 50, height: 50)
                        .scaledToFit()
                        .font(.title)
                    
                    Text("\(user.name) visited")
                
    
                    Text("\(location.name)")
                        .font(.title2)
                    
                    Spacer()
                    
                    Text("\"Three word review\"")
                }
                .padding()
                
                Spacer()
                
                ZStack(alignment: .trailing) {
                    
                    //Change to image. Which will default to locations image if user doesn't upload image with review
                    Color.OKGNBlue
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("7.8")
                            .padding(12)
                            .background(Color.OKGNDarkYellow)
                            .clipShape(Capsule())
                            .padding()
                        
                        Spacer()
                        
                        
                    }
                }
                .frame(width: 180)
            }
        }
        .frame(height: 180)
        
        .padding()
    }
}

struct ReviewCell_Previews: PreviewProvider {
    static var previews: some View {
        ReviewCell(user: MockUser.mockUser)
    }
}
