//
//  HomePageView.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-01-21.
//

import SwiftUI
import UIKit
import CloudKit

struct HomePageView: View {
    
    @EnvironmentObject var reviewManager: ReviewManager
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.dynamicTypeSize) var typeSize
    
    @ObservedObject var viewModel = HomePageViewModel()
    @StateObject var friendManager = FriendManager()
    @Binding var tabSelection: TabBarItem
    
    let cacheManager = CacheManager.instance
    
    var body: some View {
        
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 24)
                
                TrophyScrollView(categoryVisitCounts: reviewManager.eachCategoryVisitCount)
                    .padding(.bottom, 8)

                iconView
                    .padding(.top, 4)
                
                carouselView
                    .padding(.top, 8)
                
                Spacer()
            }
            
            userHeaderBar
            
            if viewModel.isShowingDetailedModalView {
                Color(.systemBackground)
                    .ignoresSafeArea(.all)
                    .opacity(0.5)
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
        .sheet(isPresented: $viewModel.showSettingsView, content: {
            SettingsView()
        })
        .background(RadialGradient(gradient: Gradient(colors: [.OKGNDarkBlue, .black.opacity(0.6)]), center: .center, startRadius: 150, endRadius: 750))
        .onReceive(CloudKitManager.shared.$userRecord) { user in
            DispatchQueue.main.async {
                viewModel.getProfile()
                reviewManager.getUserReviews()
//                viewModel.requestNotifcationPermission()
            }
        }
        .onReceive(reviewManager.$userReviews) { _ in
            DispatchQueue.main.async {
                viewModel.userReviews = reviewManager.userReviews
                setAwards(reviews: viewModel.userReviews ?? [])
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    if CloudKitManager.shared.userRecord == nil {
                        viewModel.alertItem = AlertContext.cannotRetrieveProfile
                        viewModel.showAlertView = true
                    }
                }
            }
        }
        .onChange(of: tabSelection, perform: { newValue in
            if newValue == .home {
                print("Home Page on appear")
                viewModel.getProfile()
                reviewManager.getUserReviews()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    if CloudKitManager.shared.userRecord == nil {
                        viewModel.alertItem = AlertContext.cannotRetrieveProfile
                        viewModel.showAlertView = true
                    }
                }
            }
        })
        .sheet(isPresented: $viewModel.showCreateProfileScreen,
            onDismiss: {
            if let updatedName = cacheManager.getNameFromCache() {
                viewModel.profileManager.name = updatedName
            }
            
        }, content: {
            CreateProfileView(username: viewModel.profileManager.name,
                              avatarImage: viewModel.profileManager.avatar,
                              profileContext: $viewModel.profileContext,
                              createdProfileRecord: $viewModel.existingProfileRecord,
                              showCreateProfileView: $viewModel.showCreateProfileScreen)
            .onDisappear {
                viewModel.getProfile()
            }
        })
        .sheet(isPresented: $viewModel.isShowingPhotoPicker, onDismiss: {
            viewModel.existingProfileRecord == nil ? print("•Profile CREATED") : print("😍 Profile UPDATED")
            viewModel.profileContext == .create ? viewModel.createProfile() : viewModel.updateProfile()
            cacheManager.addAvatarToCache(avatar: viewModel.profileManager.avatar)
        }, content: {
            PhotoPicker(image: $viewModel.profileManager.avatar)
        })
        .alert(viewModel.alertItem?.title ?? Text(""), isPresented: $viewModel.showAlertView, actions: {
            // actions
        }, message: {
            viewModel.alertItem?.message ?? Text("")
        })
    }
    
    
    func setAwards(reviews: [OKGNReview]) {
        withAnimation(.linear(duration: 3)) {
        
            for i in 0..<reviewManager.eachCategoryVisitCount.count {
                reviewManager.eachCategoryVisitCount[i] = reviews.filter( {$0.locationCategory == categories[i].description }).count
            }
        }
    }
}


extension HomePageView {
    
    private var userHeaderBar: some View {
        VStack {
            HStack(alignment: .top) {
                HStack(alignment: .center, spacing: 8) {
                    Image(uiImage: cacheManager.getAvatarFromCache() ?? viewModel.profileManager.avatar)
                        .resizable()
                        .frame(width: 34, height: 34)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 3)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                                .foregroundColor(.white)
                        )
                    
                    Text(viewModel.profileManager.name.isEmpty ? "Create Account" : (cacheManager.getNameFromCache() ?? viewModel.profileManager.name))
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
//                        .onTapGesture {
//                            viewModel.changeNameAlertView()
//                        }
                }
                .padding(.leading, 8)
                .padding(.trailing, 12)
                .padding(.vertical, 6)
                .overlay(
                    Capsule()
                        .stroke(Color.OKGNDarkYellow, lineWidth: 1.5)
                )
                .background {
                    Capsule()
                        .fill(Color.OKGNDarkBlue.opacity(0.95))
                }
                .onTapGesture {
                    viewModel.showCreateProfileScreen.toggle()
                }
                
                Spacer()
                
                // Number of venues visited
                VenuesVisitedView(showVenuesVisitedSubCategories: $viewModel.isShowingVenuesVisitedSubCategories,
                                  allCategoriesVisitCount: reviewManager.eachCategoryVisitCount)
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 3)
                    .frame(alignment: .trailing)
                    .frame(minWidth: 140)
                
                
                Image(systemName: "gear.circle.fill")
                    .resizable()
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: 30, height: 30, alignment: .trailing)
                    .scaledToFit()
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    .onTapGesture {
                        viewModel.showSettingsView.toggle()
                    }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    
    
    private var carouselView: some View {
        
        TabView(selection: $viewModel.currentIndex) {
            ForEach(0..<6) { index in
                GeometryReader { proxy in
                    
                    let minX = proxy.frame(in: .global).minX
                    
                    let colors: [Color] = [.white, .OKGNPurple, .OKGNPeach, .OKGNLightBlue, .OKGNPink, .OKGNLightGreen]
                    let titleColor: Color = colors[index]

                    VStack(spacing: 0) {
                        LinearGradient(colors: [titleColor, Color.OKGNDarkYellow],
                                       startPoint: .leading,
                                       endPoint: .trailing)
                        .padding(.vertical, 4)
                        .frame(minHeight: typeSize >= .accessibility1 ? 60 : 36)
                        .mask {
                            Text(index == 0 ? "Champions" : "\(categories[index-1].description) Leaders")
                                .font(.title2.weight(.semibold))
                                .minimumScaleFactor(0.9)
                                .padding(.vertical, 8)
                        }
                        
                        if index == 0 && reviewManager.userReviews.isEmpty {
                            HStack {
                                Spacer()
                                    Text("You haven't visited any locations yet!")
                                        .createNoVisitsBanner(minX: minX, color: Color.OKGNDarkYellow)
                                Spacer()
                            }
                        } else if index > 0 && reviewManager.userReviews.filter({ $0.locationCategory == categories[index - 1].description }).isEmpty {
                            HStack {
                                Spacer()
                                    Text("You haven't visited any \(categories[index-1].description) locations yet!")
                                        .createNoVisitsBanner(minX: minX, color: categories[index - 1].color)

                                Spacer()
                            }
                        } else {
             
                            TopRatedScrollView(isShowingTopRatedFilterAlert: $viewModel.isShowingTopRatedFilterAlert,
                                           isShowingDetailedModalView: $viewModel.isShowingDetailedModalView,
                                           detailedReviewToShow: $viewModel.detailedReviewToShow,
                                           topRatedFilter: index == 0 ? nil : categories[index - 1],
                                           reviews: reviewManager.userReviews,
                                           isFriendReviews: false)
                            .frame(height: 420)
                            .rotation3DEffect(.degrees(minX / -10), axis: (x: 0, y: 1, z: 0))
                            
      
                        }
                        
                        Spacer().frame(height: 500)
                    }
                    
                    //******* Add highlight around carousel view
                    
//                    .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 30, style: .continuous)
//                            .stroke(
//                                LinearGradient(colors: [.white, .clear],
//                                               startPoint: .top,
//                                               endPoint: .bottom)
//                                , lineWidth: 1)
//                            .padding(.horizontal, 24)
//                            .offset(x: minX / 2)
//                            .blendMode(.overlay)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 30, style: .continuous)
//                                    .stroke(
//                                        LinearGradient(colors: [.white, .clear],
//                                                       startPoint: .top,
//                                                       endPoint: .bottom)
//                                        , lineWidth: 2)
//                                    .padding(.horizontal, 24)
//                                    .offset(x: minX / 2)
//                                    .blur(radius: 3)
//                            )
//                    )
                    .background(
                        VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .padding(.top, 20)
                            .padding(.horizontal, 20)
                            .offset(x: minX / 2)
                            .offset(y: -20)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 10)
                    .blur(radius: abs(minX / 90))
                }
                .padding(.bottom)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: (screen.height / 2) + 20)
        .onChange(of: viewModel.currentIndex) { value in
            if value == 0 {
                withAnimation(.linear(duration: 1.5)) {
                    viewModel.topRatedFilter = nil
                }
                
            } else {
                withAnimation(.linear(duration: 1.5)) {
                    viewModel.topRatedFilter = categories[value - 1]
                }
            }
        }
    }
    
    
    
    
    private var iconView: some View {
        
        VStack {
            HStack(spacing: 20) {
                
                Image("GoldTrophy")
                    .createIconView(isActive: viewModel.topRatedFilter == nil)
                    .onTapGesture {
                        withAnimation(.linear) {
                            viewModel.topRatedFilter = nil
                            viewModel.currentIndex = 0
                        }
                    }
                    
                
                ForEach(0..<categories.count, id: \.self) { index in
                    
                    let category = categories[index]
                    
                    category.trophyImage
                        .createIconView(isActive: viewModel.topRatedFilter == category)
                        .onTapGesture {
                            withAnimation(.linear) {
                                viewModel.topRatedFilter = category
                                viewModel.currentIndex = index + 1
                            }
                        }
                }
            }
            .frame(width: screen.width)
            .padding(.bottom, 8)
        }
        
    }
    
}
