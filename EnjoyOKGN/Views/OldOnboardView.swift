//
//  OnboardView.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-02-11.
//

import SwiftUI

struct OldOnboardView: View {
    
    @Binding var isShowingOnboardView: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button {
                    isShowingOnboardView = false
                } label: {
                    XDismissButton(color: .OKGNDarkYellow)
                        .padding()
                }

            }
            
            Spacer()
            //To-do: Add logo view
            Text("Enjoy \nOKGN")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 80)
                .foregroundColor(.OKGNDarkYellow)
                
            
            VStack(alignment: .leading, spacing: 32) {
                
//                OnboardInfoView(imageName: "building.2.crop.circle",
//                                title: "See Points of Interest",
//                                description: "Find cool places to eat, drink, or play in the Okanagan!")
//                
//                OnboardInfoView(imageName: "newspaper.circle",
//                                title: "Review and Share",
//                                description: "Review locations by sharing a photo and rating with friends!")
//                
//                OnboardInfoView(imageName: "star.circle",
//                                title: "Awarded Locations",
//                                description: "Your top rated locations will get awards, see these top locations for you and your friends so you know where to visit next!")
                
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
        }
    }
}

struct OnboardView_Previews: PreviewProvider {
    static var previews: some View {
        OldOnboardView(isShowingOnboardView: .constant(true))
    }
}

//struct OnboardInfoView: View {
//    
//    var imageName: String
//    var title: String
//    var description: String
//    
//    var body: some View {
//        HStack(spacing: 26) {
//            Image(systemName: imageName)
//                .resizable()
//                .frame(width: 50, height: 50)
//                .foregroundColor(.OKGNDarkYellow)
//            
//            VStack(alignment: .leading, spacing: 4) {
//                Text(title).bold()
//                Text(description)
//                    .foregroundColor(.secondary)
//                    .lineLimit(3)
//                    .minimumScaleFactor(0.75)
//            }
//        }
//    }
//}
