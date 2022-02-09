//
//  LocationListView.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-02-08.
//

import SwiftUI

struct LocationListView: View {
    
    @State var locations: [OKGNLocation]
    
    var body: some View {
        
        NavigationView {
            List {
                ForEach(locations) { location in
                    NavigationLink(destination: LocationDetailView(location: location)) {
                        LocationCell(location: location)
                    }
                }
            }
        }
        .onAppear {
            CloudKitManager.getLocations { result in
                switch result {
                    
                case .success(let importedLocations):
                    locations = importedLocations
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

//struct LocationListView_Previews: PreviewProvider {
//    static var previews: some View {
//        LocationListView(locations: <#[OKGNLocation]#>)
//    }
//}
