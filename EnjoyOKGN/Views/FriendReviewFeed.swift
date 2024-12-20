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
        self._tabSelection = tabSelection
        
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.OKGNDarkGray.ignoresSafeArea()
                
                reviewFeed
                
                friendList
                
                if shouldShowEmptyState {
                    EmptyReviewsView(text: emptyStateMessage)
                }
                
                if viewModel.isShowingDetailedModalView,
                   let reviewToShow = viewModel.detailedReviewToShow {
                    detailedReviewOverlay(review: reviewToShow)
                }
            }
            .alert(item: $viewModel.alertItem) { alertItem in
                Alert(
                    title: alertItem.title,
                    message: alertItem.message,
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .onReceive(CloudKitManager.shared.$profile) { profile in
                handleProfileUpdate(profile)
            }
            .onReceive(reviewManager.$allFriendsReviews) { reviews in
                viewModel.friendReviews = reviews
            }
            .onChange(of: tabSelection) { newValue in
                handleTabSelection(newValue)
            }
        }
        .background(Color.OKGNDarkGray)
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $viewModel.isShowingAddFriendAlert) {
            AddFriendModalView()
        }
    }
    
    private var shouldShowEmptyState: Bool {
        viewModel.isShowingEmptyState &&
        !viewModel.isShowingFriendsList &&
        (friendManager.friends.isEmpty || reviewManager.allFriendsReviews.isEmpty)
    }
    
    private var emptyStateMessage: String {
        if friendManager.friends.isEmpty {
            return "It seems like you don't have any friends 😬 \n\nAdd some to see their reviews here!"
        } else {
            return "It seems like your friends haven't posted any reviews yet! \n\nInvite them to your favourite spot and see what they think!"
        }
    }
    
    private var navigationTitle: String {
        switch (viewModel.isShowingFriendsList, isShowingMyReviews) {
        case (true, _): return "Friends"
        case (false, true): return "My Reviews"
        default: return "Friend's Reviews"
        }
    }
    
    private func handleProfileUpdate(_ profile: CKRecord?) {
        DispatchQueue.main.async {
            if let profile = profile {
                friendManager.friendMediator(for: profile)
            }
        }
    }
    
    private func handleTabSelection(_ newValue: TabBarItem) {
        guard newValue == .feed else { return }
        
        reviewManager.getAllFriendsReviews()
        friendManager.compareRequestsAndFriends()
        viewModel.displayFollowRequests()
        
        // Reduce delay and add error handling
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if CloudKitManager.shared.userRecord == nil {
                viewModel.alertItem = AlertContext.cannotRetrieveProfile
            }
            viewModel.isShowingEmptyState = (isShowingMyReviews && reviewManager.userReviews.isEmpty) ||
                (!isShowingMyReviews && (reviewManager.allFriendsReviews.isEmpty || friendManager.friends.isEmpty))
        }
    }
}

extension FriendReviewFeed {
    private var friendList: some View {
        VStack {
            List {
                ForEach(friendManager.friends) { friend in
                    NavigationLink(destination: FriendProfileView(friend: friend)) {
                        FriendCell(profile: friend)
                    }
                }
                .onDelete { index in
                    friendManager.deleteFriends(index: index)
                }
                .listRowBackground(Color.OKGNDarkGray)
            }
            .listStyle(.plain)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.OKGNDarkGray)
        .padding(.bottom, 44)
        .alert(item: $viewModel.twoButtonAlertItem) { alertItem in
            Alert(
                title: alertItem.title,
                message: alertItem.message,
                primaryButton: .default(Text("Accept")) {
                    if let request = viewModel.friendRequest {
                        friendManager.removeRequestAfterAccepting(follower: request)
                        friendManager.acceptFriend(request)
                    }
                },
                secondaryButton: .cancel(Text("Decline")) {
                    Task {
                        if let request = viewModel.friendRequest {
                            await viewModel.declineRequest(request: request.recordID)
                        }
                    }
                }
            )
        }
        .listStyle(.plain)
        .offset(x: viewModel.isShowingFriendsList ? 0 : screen.width)
        
    }
    
    private var reviewFeed: some View {
        ScrollView {
            LazyVStack {
                if let blockList = CloudKitManager.shared.profile?.convertToOKGNProfile().blockList {
                    let filteredReviews = getFilteredReviews(blockList: blockList)
                    
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
                                if reviewIndex == reviewManager.allFriendsReviews.count - 1 {
                                    reviewManager.getAllFriendsReviews()
                                }
                            }
                    }
                    .listRowBackground(Color.OKGNDarkGray)
                }
            }
        }
        .padding(.bottom, 44)
        .refreshable { await reviewManager.refreshReviewFeed() }
    }
    
    private func getFilteredReviews(blockList: [CKRecord.Reference]) -> [OKGNReview] {
        if isShowingMyReviews {
            return reviewManager.userReviews
        } else {
            return reviewManager.allFriendsReviews.filter { review in
                !blockList.contains(where: { $0.recordID == review.reviewer.recordID })
            }
        }
    }
    
    private func detailedReviewOverlay(review: OKGNReview) -> some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
                .opacity(0.4)
                .transition(.opacity)
                .animation(.easeOut, value: viewModel.isShowingDetailedModalView)
                .zIndex(1)
            
            DetailedVisitModalView(
                review: review,
                isShowingDetailedVisitView: $viewModel.isShowingDetailedModalView
            )
            .transition(.opacity.combined(with: .slide))
            .animation(.easeOut, value: viewModel.isShowingDetailedModalView)
            .zIndex(2)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                handleTrailingButtonTap()
            } label: {
                Image(systemName: getTrailingButtonIcon())
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
    }
    
    private func handleTrailingButtonTap() {
        if viewModel.isShowingFriendsList {
            viewModel.isShowingAddFriendAlert = true
        } else {
            reviewManager.allFriendsReviews = []
            reviewManager.cursor = nil
            isShowingMyReviews.toggle()
            isShowingMyReviews ? reviewManager.getUserReviews() : reviewManager.getAllFriendsReviews()
        }
    }
    
    private func getTrailingButtonIcon() -> String {
        if viewModel.isShowingFriendsList {
            return "plus"
        } else {
            return isShowingMyReviews ? "person.2.wave.2.fill" : "person.bubble"
        }
    }
}

struct EmptyReviewsView: View {
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
