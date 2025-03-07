import SwiftUI
import CloudKit


struct AddFriendModalView: View {
    
    @ObservedObject private var viewModel = AddFriendViewModel()
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.OKGNDarkGray.ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    userList
                }
            }
            .alert(item: $viewModel.alertItem) { alertItem in
                Alert(title: alertItem.title,
                      message: alertItem.message,
                      dismissButton: alertItem.dismissButton)
            }
            .navigationTitle("Add a new friend")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, prompt: "Search users")
            .onChange(of: viewModel.searchText) { newValue in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if newValue == viewModel.searchText {
                        viewModel.debouncedSearchText = newValue
                    }
                }
            }
            .foregroundStyle(Color.white)
            .task {
                await viewModel.loadInitialData()
            }
        }
    }
}

extension AddFriendModalView {
    
    private var userList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.searchResults, id: \.id) { user in
                    UserRowView(user: user,
                                isRequested: viewModel.hasRequestedFriend(user),
                                onAddFriend: { viewModel.addFriend(friendRecord: CKRecord(recordType: "OKGNProfile", recordID: user.id)) },
                                onCancelRequest: { viewModel.cancelRequest(request: user.id) })
                    .onAppear {
                        if user == viewModel.searchResults.last {
                            Task { await viewModel.loadMoreUsers() }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }
}


struct AddFriendModalView_Previews: PreviewProvider {
    static var previews: some View {
        AddFriendModalView()
    }
}
