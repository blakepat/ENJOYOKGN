//
//  TopRatedScrollView.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-03-17.
//

import SwiftUI


struct TopRatedScrollView: View {
    
    @EnvironmentObject var reviewManager: ReviewManager
    
    @Binding var isShowingTopRatedFilterAlert: Bool
    @Binding var isShowingDetailedModalView: Bool
    @Binding var detailedReviewToShow: OKGNReview?
    @State var topRatedFilter: Category?
    @State var reviews: [OKGNReview]
    @State var isFriendReviews: Bool
    
    let rows: [GridItem] = Array(repeating: .init(.flexible()), count: 1)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Top Rated Visits:")
                .foregroundColor(.white)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top)
            
            HStack {
                Text("Sort:")
                    .foregroundColor(.gray)
                
                Text("\(topRatedFilter == nil ? "all" : topRatedFilter!.description)")
                    .foregroundColor(.white)
                
                Text("▼")
                    .font(.footnote)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 4)
            .onTapGesture {
                isShowingTopRatedFilterAlert.toggle()
            }
            .alert("See Top Rated For:", isPresented: $isShowingTopRatedFilterAlert) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        topRatedFilter = category
                    } label: {
                        Text(category.description)
                    }
                }
                Button("All") {
                    topRatedFilter = nil
                }
                
                Button("Cancel", role: .cancel) {
                    isShowingTopRatedFilterAlert = false
                }
            }
            
            ScrollView(.vertical) {
                LazyVGrid(columns: rows) {
                    
                    let reviews = isFriendReviews ? reviewManager.friendReviews : reviewManager.userReviews
                    
                    ForEach(reviews.filter({topRatedFilter == nil ? $0.ranking == .first : returnCategoryFromString($0.locationCategory)  == topRatedFilter && ($0.ranking == .first || $0.ranking == .second || $0.ranking == .third) })) { review in
                        ReviewCell(review: review)
                            .padding(.horizontal, 4)
                            .onTapGesture {
                                detailedReviewToShow = review
                                withAnimation {
                                    isShowingDetailedModalView = true
                                }
                            }
                    }
                }
            }
        }
        .padding(.horizontal, 8)
    }
}
