//
//  LocationDetailView.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-02-08.
//

import SwiftUI

struct LocationDetailView: View {
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var location: OKGNLocation
    
    var body: some View {
        VStack(spacing: 16) {
            BannerImageView(image: location.createBannerImage())
            
            HStack {
                AddressView(address: location.address)
                
                Spacer()
            }
            .padding(.horizontal)
            
            DescriptionView(text: location.description)
                
            
            ZStack {
                Capsule()
                    .frame(height: 80)
                    .foregroundColor(Color(.secondarySystemBackground))
                
                HStack(spacing: 20) {
                    Button {
                        
                    } label: {
                        LocationActionButton(color: .OKGNDarkYellow, imageName: "location.fill")
                    }
                    
                    Link(destination: URL(string: location.websiteURL)!) {
                        LocationActionButton(color: .OKGNDarkYellow, imageName: "network")
                    }
                    
                    Button {
                        
                    } label: {
                        LocationActionButton(color: .OKGNDarkYellow, imageName: "phone.fill")
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle(location.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LocationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LocationDetailView(location: OKGNLocation(record: MockData.location))
        }
    }
}

struct LocationActionButton: View {
    
    var color: Color
    var imageName: String
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(color)
                .frame(width: 60, height: 60, alignment: .center)
            
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: 22, height: 22, alignment: .center)
        }
    }
}


//struct FirstNameAvatarView: View {
//    
//    var firstName: String
//    var image: UIImage
//    
//    var body: some View {
//        
//        VStack {
//            AvatarView(size: 64, image: image)
//            
//            Text(firstName)
//                .bold()
//                .lineLimit(1)
//                .minimumScaleFactor(0.75)
//        }
//    }
//}

struct BannerImageView: View {
    var image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(height: 120)
            .clipped()
    }
}

struct AddressView: View {
    
    var address: String
    var body: some View {
        Label(address, systemImage: "mappin.and.ellipse")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}

struct DescriptionView: View {
    var text: String
    var body: some View {
        Text(text)
            .font(.body)
            .lineLimit(3)
            .minimumScaleFactor(0.75)
            .frame(height: 70)
            .padding(.horizontal)
    }
}

