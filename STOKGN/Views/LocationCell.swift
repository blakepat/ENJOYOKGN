//
//  LocationCell.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-02-08.
//

import SwiftUI

struct LocationCell: View {
    
    var location: OKGNLocation
    
    var body: some View {
        HStack {
            Image(uiImage: location.createSquareImage())
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .padding(.vertical, 8)
            
            VStack(alignment: .leading) {
                Text(location.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
                
            }
            .padding(.leading)
        }
    }
}

//struct LocationCell_Previews: PreviewProvider {
//    static var previews: some View {
//        LocationCell(location: OKGNLocation(record: MockData.location))
//    }
//}
