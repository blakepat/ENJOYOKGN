//
//  FriendProfileView.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-03-17.
//

import SwiftUI

struct FriendProfileView: View {
    
    @StateObject var viewModel = FriendProfileViewModel()
    var friend: OKGNProfile
    
    var body: some View {
        
        ZStack {
            
            Color.OKGNDarkGray.edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading) {
                
                ZStack {
                    RoundedRectangle(cornerRadius: 16).stroke(lineWidth: 8)
                        .foregroundColor(.OKGNDarkYellow)
                    
                    HStack {
                        //Avatar
                        Image(uiImage: friend.avatar.convertToUIImage(in: .square))
                            .resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .scaledToFit()
                        
                        //Friend Name
                        Text(friend.name)
                            .font(.title)
                        
                        Spacer()
                    
                    }
                    .padding(.leading)
                }
                .padding(.horizontal)
                .frame(height: 120)
                
                
                //trophies
                TrophyScrollView(pizzeriaCount: 3,
                                 wineryCount: 6,
                                 breweryCount: 10,
                                 cafeCount: 2,
                                 activityCount: 0)
                
                
                //top rated reviews (similar to home page)
                TopRatedScrollView(isShowingTopRatedFilterAlert: $viewModel.isShowingTopRatedFilterAlert,
                                   isShowingDetailedModalView: $viewModel.isShowingDetailedModalView,
                                   topRatedFilter: viewModel.topRatedFilter,
                                   detailedReviewToShow: viewModel.detailedReviewToShow)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FriendProfileView_Previews: PreviewProvider {
    static var previews: some View {
        FriendProfileView(friend: MockData.mockUser.convertToOKGNProfile())
    }
}
