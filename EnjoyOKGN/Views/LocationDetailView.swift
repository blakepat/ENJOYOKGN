//
//  LocationDetailView.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-02-08.
//

import SwiftUI

struct LocationDetailView: View {
    
    @ObservedObject var viewModel: LocationDetailViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                BannerImageView(image: viewModel.locationBannerImage!)
                
                HStack {
                    AddressView(address: viewModel.location?.address ?? "")
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                DescriptionView(text: viewModel.location?.description ?? "")
                    
                    HStack(spacing: 20) {
                        Button {
                            viewModel.getDirectionsToLocation()
                        } label: {
                            LocationActionButton(color: .OKGNDarkYellow, imageName: "location.fill")
                        }
                        
                        Link(destination: URL(string: viewModel.location?.websiteURL ?? "https://www.google.com")!) {
                            LocationActionButton(color: .OKGNDarkYellow, imageName: "network")
                        }
                        if viewModel.location?.phoneNumber != nil {
                            Button {
                            
                                viewModel.callLocation()
                            } label: {
                                LocationActionButton(color: .OKGNDarkYellow, imageName: "phone.fill")
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(6)
                    .background(VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight)))
                    .clipShape(Capsule())
                                  
                
                ReviewToggle(showFriendsReviews: $viewModel.showFriendsReviews)
                
                ScrollView {
                    LazyVStack {
                        ForEach((viewModel.showFriendsReviews ? viewModel.friendsReviews : viewModel.reviews).indices, id: \.self) { reviewIndex in
                            
                            let reviews = viewModel.showFriendsReviews ? viewModel.friendsReviews : viewModel.reviews

                            ReviewCell(review: reviews[reviewIndex], showTrophy: true, height: 120)
                                .listRowBackground(Color.clear)
                                .padding(.horizontal, 4)
                                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                                .onTapGesture {
                                    viewModel.detailedReviewToShow = reviews[reviewIndex]
                                    withAnimation {
                                        viewModel.isShowingDetailedModalView = true
                                    }
                                }
                                .onAppear {
                                    if reviewIndex == (viewModel.showFriendsReviews ? viewModel.friendsReviews : viewModel.reviews).count {
                                        viewModel.getUserReviewsForThisLocation()
                                    }
                                }
                        }
                        .onDelete { index in
                            
                            let recordToDelete = viewModel.reviews[index[index.startIndex]]
                            viewModel.reviews.remove(atOffsets: index)
                            
                            Task {
                                do {
                                    let deletedRecordIDs = try await CloudKitManager.shared.deleteRecord(recordID: recordToDelete.id)
                                    print("💜 \(String(describing: deletedRecordIDs))")
                                } catch {
                                    print("❌ Failed deleting record")
                                }
                            }
                        }
                        Spacer().frame(height: 70)
                    }
                    .listStyle(.plain)
                }
                .padding(.horizontal)
            }
            .background(LinearGradient(gradient: Gradient(colors: [returnCategoryFromString(viewModel.location?.category ?? "Activity").color, .black.opacity(0.5)]), startPoint: .top, endPoint: .bottom))
            .navigationTitle(viewModel.location?.name ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if viewModel.isFavourited {
                            //unfavourite location
                            viewModel.unfavouriteLocation()
                        } else {
                            viewModel.favouriteLocation()
                        }
                        
                        viewModel.isFavourited.toggle()
                    } label: {
                        Image(systemName: viewModel.isFavourited ? "star.fill" : "star")
                    }

                }
            })
            .alert(viewModel.alertItem?.title ?? Text(""), isPresented: $viewModel.showAlertView, actions: {
            }, message: {
                viewModel.alertItem?.message ?? Text("")
            })
            
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
        .onAppear {
            viewModel.checkIfLocationIsFavourited()
            viewModel.getUserReviewsForThisLocation()
            viewModel.locationBannerImage = viewModel.location?.createBannerImage()
        }
        .onReceive(viewModel.reviewManager.$allFriendsReviews) { reviewsForThisLocation in
            viewModel.friendsReviews = reviewsForThisLocation
        }
    }
}

struct LocationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LocationDetailView(viewModel: LocationDetailViewModel(location: OKGNLocation(record: MockData.location)))
        }
    }
}


struct LocationActionButton: View {
    
    var color: Color
    var imageName: String
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(color)
                .frame(width: 60, height: 60, alignment: .center)
            
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: 22, height: 22, alignment: .center)
        }
    }
}


struct ReviewToggle: View {
    
    @Binding var showFriendsReviews: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("My Reviews")
                    .font(.headline)
                    .padding(.horizontal, 30)
                    .foregroundColor(showFriendsReviews ? .gray : .OKGNDarkYellow)
                    .frame(width: screen.size.width / 2 - 1)
                    .onTapGesture {
                        withAnimation {
                            showFriendsReviews.toggle()
                        }
                    }

                Divider()
                    .frame(height: 30)
                
                Text("Friends Reviews")
                    .font(.headline)
                    .padding(.horizontal, 30)
                    .foregroundColor(showFriendsReviews ? .OKGNDarkYellow : .gray)
                    .frame(width: screen.size.width / 2 - 1)
                    .onTapGesture {
                        withAnimation {
                            showFriendsReviews.toggle()
                        }
                    }
            }
            .font(.system(size: 24, weight: .bold))
            
            ZStack {
                Color(white: 0.5, opacity: 0.5)
                    .frame(width: screen.width, height: 1, alignment: .center)
                Color.OKGNDarkYellow
                    .frame(width: screen.width / 2, height: 4, alignment: .leading)
                    .position(x: withAnimation {
                        showFriendsReviews ? screen.width / 2 + screen.width / 4 : 0 + screen.width / 4
                    })
                    
            }
            .frame(width: screen.width, height: 4, alignment: .center)
        }
    }
}


struct BannerImageView: View {
    var image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(height: 120)
            .clipped()
    }
}


struct AddressView: View {
    
    var address: String
    var body: some View {
        Label(address, systemImage: "mappin.and.ellipse")
            .font(.caption)
            .foregroundColor(.secondary)
            .minimumScaleFactor(0.7)
            .fixedSize(horizontal: false, vertical: true)
    }
}


struct DescriptionView: View {
    var text: String
    var body: some View {
        Text(text)
            .font(.body)
            .minimumScaleFactor(0.75)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal)
    }
}

