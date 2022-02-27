//
//  FriendReviewFeed.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-22.
//

import SwiftUI
import CloudKit

struct FriendReviewFeed: View {
    
    @EnvironmentObject var reviewManager: ReviewManager
    @EnvironmentObject var profileManager: ProfileManager
    @ObservedObject var viewModel = FriendReviewFeedModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                
                Color.OKGNDarkGray
                    .edgesIgnoringSafeArea(.top)
                
                ScrollView {
                    
                    if viewModel.isShowingFriendsList {
                        ForEach(viewModel.friendManager.friends) { friend in
                            FriendCell(profile: friend)
                        }
                    } else {
                        ForEach(reviewManager.reviews) { review in
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
                
                if let profile = CloudKitManager.shared.profileRecordID {
                    viewModel.friendManager.getFriends(friendList: CKRecord.Reference(recordID: profile, action: .none)) { result in
                        switch result {
                        case .success(let friends):
                            print("✅ Success getting friends list")
                            viewModel.friendManager.friends = friends
                        case .failure(_):
                            print("❌ Error getting friend list")
                        }
                    }
                }
                
                if let profileRecordID = CloudKitManager.shared.profileRecordID {
                    viewModel.friendManager.acceptFriendRequest(profileReference: CKRecord.Reference(recordID: profileRecordID, action: .none)) { result in
                        switch result {
                        case .success(let friendRequests):
                            print("✅ Success getting friend requests")
                            DispatchQueue.main.async {
                                for friend in friendRequests {
                                    
                                    guard let userProfile = CloudKitManager.shared.profile else {
                                        //TO-DO: create alert for unable to get profile
                                        return
                                    }
                                    
                                    if userProfile.convertToOKGNProfile().friends.contains(CKRecord.Reference(recordID: friend.recordID, action: .none)) {
                                        return
                                    }
                                    
                                    viewModel.twoButtonAlertItem = TwoButtonAlertItem(title: Text("Friend Request!"),
                                                                                      message: Text("\(friend.convertToOKGNProfile().name) sent you a friend request!"),
                                                                                      acceptButton: .default(Text("Accept"), action: {
                                        viewModel.friendManager.addFriend(friendName: friend.convertToOKGNProfile().name) { result in
                                            switch result {

                                            case .success(_):
                                                userProfile[OKGNProfile.kFriends] = [CKRecord.Reference(record: friend, action: .none)]
                                                CloudKitManager.shared.save(record: userProfile) { result in
                                                    switch result {
                                                    case .success(_):
                                                        print("✅friend added!")
                                                    case .failure(let error):
                                                        print("❌ failed adding friend")
                                                        print(error)
                                                    }
                                                }
                                            case .failure(_):
                                                print("")
                                            }
                                        }
                                    }),
                                                                                      dismissButton: .cancel(Text("Decline"), action: {
                                        //🥶 TO-DO: Decline friend request
                                        print("🥶 Friend Request Declined")

                                    }))
                                }
                            }

                        case .failure(_):
                            print("❌ Error creating friend requests")
                        }
                    }
                }
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
