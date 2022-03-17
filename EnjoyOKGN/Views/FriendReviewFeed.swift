//
//  FriendReviewFeed.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-22.
//

import SwiftUI
import CloudKit

struct FriendReviewFeed: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var reviewManager: ReviewManager
    @EnvironmentObject var profileManager: ProfileManager
    @StateObject var friendManager = FriendManager()
    @ObservedObject var viewModel = FriendReviewFeedModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                
                (colorScheme == .dark ? Color.OKGNDarkGray : Color.white)
                    .edgesIgnoringSafeArea(.all)
                
                List {
                    if viewModel.isShowingFriendsList {
                        ForEach(friendManager.friends) { friend in
                            NavigationLink(destination: FriendProfileView(friend: friend)) {
                                FriendCell(profile: friend)
                                    .padding(.horizontal)
                            }
                        }
                        .onDelete { index in
                            friendManager.deleteFriends(index: index)
                        }
                        .listRowBackground(Color.OKGNDarkGray)
                        
                    } else {
                        ForEach(reviewManager.friendsReviews) { review in
                            ReviewCell(review: review)
                                .padding(.horizontal)
                                .onTapGesture {
                                    withAnimation {
                                        viewModel.isShowingDetailedModalView = true
                                    }
                                    viewModel.detailedReviewToShow = review
                                }
                        }
                        .listRowBackground(Color.OKGNDarkGray)
                    }
                }
                .listStyle(.plain)
                
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
            .navigationTitle(viewModel.isShowingFriendsList ? "Friends" : "Friend's Reviews")
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
            .onReceive(CloudKitManager.shared.$profile) { _ in
                DispatchQueue.main.async {
                    if let profile = CloudKitManager.shared.profile {
                        friendManager.friendMediator(for: profile)
                    }
                }
            }
            .onAppear {
                reviewManager.getFriendsReviews()
                friendManager.compareRequestsAndFriends()
                viewModel.displayFollowRequests()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // This is called so there is issues with constraints in console
        .alert(item: $viewModel.twoButtonAlertItem, content: { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, primaryButton: alertItem.acceptButton, secondaryButton: alertItem.dismissButton)
        })
    }
}

//struct FriendReviewFeed_Previews: PreviewProvider {
//    static var previews: some View {
//        FriendReviewFeed(reviewManager: ReviewManager())
//    }
//}
