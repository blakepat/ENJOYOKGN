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
    @StateObject var viewModel = FriendReviewFeedModel()
    
    
    init() {
        UITableView.appearance().backgroundColor = UIColor(named: "OKGNDarkGray")
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : UIColor.white]
    }
    
    
    var body: some View {
        NavigationView {
            ZStack {
                
                Color.OKGNDarkGray.ignoresSafeArea()
                
                if viewModel.isShowingFriendsList {
                        List {
                            ForEach(friendManager.friends) { friend in
                                HStack {
                                    NavigationLink(destination: FriendProfileView(friend: friend)) {
                                        HStack {
                                            FriendCell(profile: friend, userReviews: viewModel.friendReviews?.filter({ $0.reviewerName == friend.name }) ?? [])
                                        }
                                    }
                                }
                            }
                            .onDelete { index in
                                friendManager.deleteFriends(index: index)
                            }
                            .listRowBackground(Color.OKGNDarkGray)
                        }
                        .listStyle(.plain)
                        .transition(.move(edge: .leading))
                    
                    }
                
                    if !viewModel.isShowingFriendsList {
                        List {
                            ForEach(reviewManager.allFriendsReviews.sorted { viewModel.reviewsSortedByRating ? $0.rating > $1.rating : $0.date > $1.date } ) { review in
                                ReviewCell(review: review)
                                    .transition(.move(edge: .trailing))
                                    .onTapGesture {
                                        withAnimation {
                                            viewModel.isShowingDetailedModalView = true
                                            viewModel.detailedReviewToShow = review
                                        }
                                    }
                            }
                            .listRowBackground(Color.OKGNDarkGray)
                        }
                        .listStyle(.plain)
                        .transition(.move(edge: .trailing))
                        
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
            .navigationTitle(viewModel.isShowingFriendsList ? "Friends" : "Friend's Reviews")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if viewModel.isShowingFriendsList {
                            //Add friend
                            viewModel.isShowingAddFriendAlert = true
                            viewModel.showFriendSearchView()
                        } else {
                            //display top restaurants
                            viewModel.reviewsSortedByRating.toggle()
                        }
                        
                        
                    } label: {
                        Image(systemName: viewModel.isShowingFriendsList ? "plus" : viewModel.reviewsSortedByRating ? "calendar.badge.clock" : "list.number")
                            .foregroundColor(Color.OKGNDarkYellow)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: viewModel.isShowingFriendsList ? "list.bullet.rectangle.fill" : "person.3.fill")
                        .onTapGesture {
                            withAnimation {
                                viewModel.isShowingFriendsList.toggle()
                            }
                        }
                        .foregroundColor(Color.OKGNDarkYellow)
                }
            })
            .onReceive(CloudKitManager.shared.$profile) { _ in
                DispatchQueue.main.async {
                    if let profile = CloudKitManager.shared.profile {
                        friendManager.friendMediator(for: profile)
                    }
                }
            }
            .onReceive(reviewManager.$allFriendsReviews) { _ in
                DispatchQueue.main.async {
                    viewModel.friendReviews = reviewManager.allFriendsReviews
                }
            }
            .onAppear {
                reviewManager.getAllFriendsReviews()
                friendManager.compareRequestsAndFriends()
                viewModel.displayFollowRequests()
            }
        }
        .background(Color.OKGNDarkGray)
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
