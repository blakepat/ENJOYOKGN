//
//  FriendProfileView.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-03-17.
//

import SwiftUI

struct FriendProfileView: View {
    
    @EnvironmentObject var reviewManager: ReviewManager
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
                TrophyScrollView(pizzeriaCount: viewModel.pizzeriaCount,
                                 wineryCount: viewModel.wineryCount,
                                 breweryCount: viewModel.breweryCount,
                                 cafeCount: viewModel.cafeCount,
                                 activityCount: viewModel.activityCount)
                
                
                //top rated reviews (similar to home page)
                TopRatedScrollView(isShowingTopRatedFilterAlert: $viewModel.isShowingTopRatedFilterAlert,
                                   isShowingDetailedModalView: $viewModel.isShowingDetailedModalView,
                                   detailedReviewToShow: $viewModel.detailedReviewToShow,
                                   topRatedFilter: viewModel.topRatedFilter,
                                   reviews: reviewManager.friendReviews,
                                   isFriendReviews: true)
            }
            
            
            
            if viewModel.isShowingDetailedModalView {
                Color(.systemBackground)
                    .ignoresSafeArea(.all)
                    .opacity(0.4)
                    .transition(.opacity)
                    .animation(.easeOut, value: viewModel.isShowingDetailedModalView)
                    .zIndex(1)
                
                if let reviewToShow = viewModel.detailedReviewToShow {
                    DetailedVisitModalView(review: reviewToShow, isShowingDetailedVisitView: $viewModel.isShowingDetailedModalView)
                        .transition(.opacity.combined(with: .slide))
                        .animation(.easeOut, value: viewModel.isShowingDetailedModalView)
                        .zIndex(2)
                }
            }
            
            
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(reviewManager.$friendReviews) { _ in
            DispatchQueue.main.async {
                viewModel.friendReviews = reviewManager.friendReviews
            }
        }
        .task {
            reviewManager.getOneFriendReviews(id: friend.id)
        }
    }
}

struct FriendProfileView_Previews: PreviewProvider {
    static var previews: some View {
        FriendProfileView(friend: MockData.mockUser.convertToOKGNProfile())
    }
}
