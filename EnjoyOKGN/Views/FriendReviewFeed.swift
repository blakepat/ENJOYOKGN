//
//  FriendReviewFeed.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-22.
//

import SwiftUI

struct FriendReviewFeed: View {
    
    @EnvironmentObject var reviewManager: ReviewManager
    @ObservedObject var viewModel = FriendReviewFeedModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                
                Color.OKGNDarkGray
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    ForEach(reviewManager.reviews) { review in
                        
                        if viewModel.isShowingFriendsList {
                            FriendCell(profile: MockData.mockUser.convertToOKGNProfile())
                        } else {
                            ReviewCell(review: review)
                                .onTapGesture {
                                    withAnimation {
                                        viewModel.isShowingDetailedModalView = true
                                    }
                                    viewModel.detailedReviewToShow = review
                                }
                        }
                    }
                }
                .padding(.horizontal)
                .navigationTitle("Friend's Reviews")
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            //Add friend
                            viewModel.isShowingAddFriendAlert = true
                            viewModel.showFriendSearchView()
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            viewModel.isShowingFriendsList.toggle()
                        } label: {
                            Text(viewModel.isShowingFriendsList ? "Reviews" : "Friends")
                                .foregroundColor(.blue)
                        }
                    }
                })
                .onAppear {
                    reviewManager.getReviews()
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
        }
    }
}

//struct FriendReviewFeed_Previews: PreviewProvider {
//    static var previews: some View {
//        FriendReviewFeed(reviewManager: ReviewManager())
//    }
//}
