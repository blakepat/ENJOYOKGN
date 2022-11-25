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
    
    @State private var currentIndex = 0
    var category: Category?
    
    var body: some View {
        
        ZStack {
            Color.OKGNDarkGray.edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading) {
                
                friendNamePlate
                
                TrophyScrollView(categoryVisitCounts: viewModel.categoryVisitCounts)
                
                categoryIconView
                
                friendCarouselView
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


extension FriendProfileView {
    
    private var friendNamePlate: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16).stroke(lineWidth: 8)
                .foregroundColor(.OKGNDarkYellow)
            
            HStack {
                //Avatar
                Image(uiImage: friend.avatar.convertToUIImage(in: .square))
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .scaledToFit()
                
                //Friend Name
                Text(friend.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            
            }
            .padding(.leading)
        }
        .padding(.horizontal)
        .frame(height: 70)
    }
    
    
    private var categoryIconView: some View {
        HStack(spacing: 20) {
            
            Image("GoldTrophy")
                .createIconView(isActive: viewModel.topRatedFilter == nil)
                .onTapGesture {
                    withAnimation {
                        viewModel.topRatedFilter = nil
                        currentIndex = 0
                    }
                }
            
            ForEach(0..<categories.count, id: \.self) { index in
                
                let category = categories[index]
                
                category.trophyImage
                    .createIconView(isActive: viewModel.topRatedFilter == category)
                    .onTapGesture {
                        withAnimation {
                            viewModel.topRatedFilter = category
                            currentIndex = index + 1
                        }
                    }
            }
        }
        .frame(width: screen.width, height: 48)
        .padding(.bottom, 8)
    }

    
    private var friendCarouselView: some View {
        TabView(selection: $currentIndex) {
            ForEach(0..<6) { index in
                GeometryReader { proxy in
                    
                    let minX = proxy.frame(in: .global).minX
                    
                    VStack(spacing: 0) {
                        Text(index == 0 ? "Champions" : "\(categories[index-1].description) Leaders")
                            .font(.headline)
                            .padding(.vertical, 8)
                            .foregroundColor(.white)
                        
                        
                        if index > 0 && reviewManager.friendReviews.filter({ $0.locationCategory == categories[index - 1].description }).isEmpty {
                            
                            HStack {
                                
                                Spacer()
                                    Text("You haven't visited any \(categories[index-1].description) locations yet!")
                                        .createNoVisitsBanner(minX: minX, category: categories[index - 1])

                                Spacer()
                            }
                        } else {
             
                            //top rated reviews (similar to home page)
                            TopRatedScrollView(isShowingTopRatedFilterAlert: $viewModel.isShowingTopRatedFilterAlert,
                                               isShowingDetailedModalView: $viewModel.isShowingDetailedModalView,
                                               detailedReviewToShow: $viewModel.detailedReviewToShow,
                                               topRatedFilter: viewModel.topRatedFilter,
                                               reviews: reviewManager.friendReviews,
                                               isFriendReviews: true)
                            .frame(height: (screen.height / 2.4) - 40)
                            .rotation3DEffect(.degrees(minX / -10), axis: (x: 0, y: 1, z: 0))
      
                        }
                        
                        Spacer()
                    }
                    .background(
                        VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.top)
                            .padding(.horizontal, 24)
                            .offset(x: minX / 2)
                            .offset(y: -20)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 10)
                    .blur(radius: abs(minX / 80))
                }
                .padding(.bottom)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: screen.height / 2.25)
        .onChange(of: currentIndex) { value in
            if value == 0 {
                viewModel.topRatedFilter = nil
            } else {
                viewModel.topRatedFilter = categories[value - 1]
            }
        }
    }
    
    
    
}
