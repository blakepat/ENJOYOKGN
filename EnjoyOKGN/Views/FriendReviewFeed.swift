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
    
    @State private var isShowingMyReviews: Bool = false
    
    @Binding var tabSelection: TabBarItem
    
    init(tabSelection: Binding<TabBarItem>) {
        UITableView.appearance().backgroundColor = UIColor(named: "OKGNDarkGray")
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : UIColor.white]
        self._tabSelection = tabSelection
    }
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.OKGNDarkGray.ignoresSafeArea()
                
                reviewFeed
    
                friendList
                
   
                if friendManager.friends.isEmpty && viewModel.isShowingEmptyState && !viewModel.isShowingFriendsList {
                    emptyReviewsView(text: "It seems like you don't have any friends 😬 \n\nAdd some to see their reviews here!")
                } else if reviewManager.allFriendsReviews.isEmpty && viewModel.isShowingEmptyState && !viewModel.isShowingFriendsList {
                    emptyReviewsView(text: "It seems like your friends haven't posted any reviews yet! \n\nInvite them to your favourite spot and see what they think!")
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
            .alert(viewModel.alertItem?.title ?? Text(""), isPresented: $viewModel.showAlertView, actions: {
                // actions
            }, message: {
                viewModel.alertItem?.message ?? Text("")
            })
            .navigationTitle(viewModel.isShowingFriendsList ? "Friends" : isShowingMyReviews ? "My Reviews" : "Friend's Reviews")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if viewModel.isShowingFriendsList {
                            viewModel.isShowingAddFriendAlert = true
                        } else {
                            reviewManager.allFriendsReviews = []
                            reviewManager.cursor = nil
//                            viewModel.reviewsSortedByRating.toggle()
                            isShowingMyReviews.toggle()
                            isShowingMyReviews ? reviewManager.getUserReviews() : reviewManager.getAllFriendsReviews()
                            
                        }
                    } label: {
                        Image(systemName: viewModel.isShowingFriendsList ? "plus" : isShowingMyReviews ? "person.2.wave.2.fill" : "person.bubble")
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
            .onChange(of: tabSelection) { newValue in
                if newValue == .feed {
                    print("FEED ON APPEAR CALLED!")
                    reviewManager.getAllFriendsReviews()
                    friendManager.compareRequestsAndFriends()
                    viewModel.displayFollowRequests()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        if CloudKitManager.shared.userRecord == nil {
                            viewModel.alertItem = AlertContext.cannotRetrieveProfile
                            viewModel.showAlertView = true
                        }
                        if (isShowingMyReviews && reviewManager.userReviews.isEmpty) ||
                            (!isShowingMyReviews && (reviewManager.allFriendsReviews.isEmpty || friendManager.friends.isEmpty)) {
                            viewModel.isShowingEmptyState = true
                        }
                    }
                }
            }
        }
        .background(Color.OKGNDarkGray)
        .navigationViewStyle(StackNavigationViewStyle()) // This is called so there isnt issues with constraints in console
        .sheet(isPresented: $viewModel.isShowingAddFriendAlert) {
            AddFriendModalView()
        }
    }
}



extension FriendReviewFeed {
    
    private var friendList: some View {
        List {
            ForEach(friendManager.friends) { friend in
                NavigationLink(destination: FriendProfileView(friend: friend)) {
                    HStack {
                        FriendCell(profile: friend)
                    }
                }
            }
            .onDelete { index in
                friendManager.deleteFriends(index: index)
            }
            .listRowBackground(Color.OKGNDarkGray)
        }
        .padding(.bottom, 44)
        .alert(viewModel.twoButtonAlertItem?.title ?? Text(""), isPresented: $viewModel.showFriendAlertView, actions: {
            HStack {
                Button {
                    friendManager.removeRequestAfterAccepting(follower: viewModel.friendRequest!)
                    friendManager.acceptFriend(viewModel.friendRequest!)
                } label: {
                    Text("Accept")
                }
                Button {
                    Task {
                        await viewModel.declineRequest(request: viewModel.friendRequest!.recordID)
                    }
                } label: {
                    Text("Decline")
                }
            }
        }, message: {
            viewModel.twoButtonAlertItem?.message ?? Text("")
        })
        .listStyle(.plain)
        .offset(x: viewModel.isShowingFriendsList ? 0 : screen.width)
    }
    
    
    private var reviewFeed: some View {
        ScrollView {
            LazyVStack {
                
                if let blockList = CloudKitManager.shared.profile?.convertToOKGNProfile().blockList {
                    let filteredReviews = isShowingMyReviews ? reviewManager.userReviews : reviewManager.allFriendsReviews.filter({ !blockList.contains($0.reviewer) })
                    
                    ForEach(filteredReviews.indices, id: \.self) { reviewIndex in

                        let review = filteredReviews[reviewIndex]

                        ReviewCell(review: review, showTrophy: false, height: 130)
                            .padding(.horizontal, 8)
                            .transition(.move(edge: .trailing))
                            .onTapGesture {
                                withAnimation {
                                    viewModel.isShowingDetailedModalView = true
                                    viewModel.detailedReviewToShow = review
                                }
                            }
                            .onAppear {
                                if reviewIndex == reviewManager.allFriendsReviews.count - 1{
                                    reviewManager.getAllFriendsReviews()
                                }
                            }
                    }
                    .listRowBackground(Color.OKGNDarkGray)
                }
            }
            .listStyle(.plain)
            .offset(x: viewModel.isShowingFriendsList ? -screen.width : 0)
        }
        .padding(.bottom, 44)
        .refreshable { await reviewManager.refreshReviewFeed() }
        .alert(viewModel.alertItem?.title ?? Text(""), isPresented: $viewModel.showFriendAlertView, actions: {
            // actions
        }, message: {
            viewModel.alertItem?.message ?? Text("")
        })
    }
}



struct emptyReviewsView: View {
    
    var text: String
    
    var body: some View {
        
        VStack {
            Spacer()
            
            Text(text)
                .multilineTextAlignment(.center)
                .font(.title)
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .opacity(0.4)
                        .foregroundColor(.OKGNDarkYellow)
                )
                .padding(.horizontal)
            
            Spacer()
        }
    }
}
