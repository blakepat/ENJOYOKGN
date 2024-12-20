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
        
        ZStack {
            VStack(alignment: .leading, spacing: 6) {
                ScrollView(.vertical) {
                    LazyVGrid(columns: rows) {
                        
                        let reviews = isFriendReviews ? reviewManager.friendReviews : reviewManager.userReviews
                        
                        ForEach(reviews.filter({ topRatedFilter == nil ? $0.ranking == .first : returnCategoryFromString($0.locationCategory) == topRatedFilter && ($0.ranking == .first || $0.ranking == .second || $0.ranking == .third) })) { review in
                            
                            VStack(spacing: 0) {
                                
                                if topRatedFilter == nil {
                                    HStack {
                                        Text("\(review.locationCategory.description) Leader")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .minimumScaleFactor(0.6)
                                        
                                        Spacer()
                                    }
                                    .padding(.leading, 32)
                                    
                                } else {
                                    Spacer(minLength: 20)
                                }
                                
                                
                                //                                ReviewCell(review: review, showTrophy: true, height: 140)
                                //                                    .frame(width: 360)
                                //                                    .padding(.horizontal, 4)
                                //                                    .onTapGesture {
                                //                                        detailedReviewToShow = review
                                //                                        withAnimation {
                                //                                            isShowingDetailedModalView = true
                                //                                        }
                                //                                    }
                                GeometryReader { geometry in
                                    HStack {
                                        Spacer()
                                        ReviewCell(review: review, showTrophy: true, height: 140)
                                            .frame(width: min(360, geometry.size.width * 0.85))
                                            .onTapGesture {
                                                detailedReviewToShow = review
                                                withAnimation {
                                                    isShowingDetailedModalView = true
                                                }
                                            }
                                        Spacer()
                                    }
                                }
                                .frame(height: 140)
                            }
                        }
                        Spacer().frame(height: 100)
                    }
                }
                
            }
            .padding(.horizontal, 8)
            //            .padding(.top, 46)
            
        }
    }
}

//
//VStack(alignment: .leading) {
//
//    HStack(alignment: .top) {
//        Text("Top Rated Visits: ")
//            .foregroundColor(.white)
//            .font(.title2)
//            .fontWeight(.semibold)
//            .padding(.top, 6)
//
//
//        DropDown(category: $topRatedFilter)
//
//        Spacer()
//
//
//    }
//    .padding(.horizontal, 12)
//    .onTapGesture {
//        isShowingTopRatedFilterAlert.toggle()
//    }
//    .alert("See Top Rated For:", isPresented: $isShowingTopRatedFilterAlert) {
//        ForEach(categories, id: \.self) { category in
//            Button {
//                topRatedFilter = category
//            } label: {
//                Text(category.description)
//            }
//        }
//        Button("All") {
//            topRatedFilter = nil
//        }
//
//        Button("Cancel", role: .cancel) {
//            isShowingTopRatedFilterAlert = false
//        }
//    }
