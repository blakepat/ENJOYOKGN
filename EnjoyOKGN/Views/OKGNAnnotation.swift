//
//  MapAnnotation.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-21.
//

import SwiftUI
import MapKit

struct OKGNAnnotation: View{
    
    var location: OKGNLocation
    
    var body: some View {
        VStack {
            
            Image(systemName: "mappin.circle.fill")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(returnCategoryFromString(location.category).color)
            
            Text(location.name)
                .font(.caption)
                .fontWeight(.semibold)
            
        }
    }
}

struct MapAnnotation_Previews: PreviewProvider {
    static var previews: some View {
        OKGNAnnotation(location: MockData.location.convertToOKGNLocation())
    }
}
