//
//  HomePageView.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-01-21.
//

import SwiftUI

struct HomePageView: View {
    
    @State var isShowingVenuesVisitedSubCategories = false
    @State var isShowingTopRatedFilterAlert = false
    @State var isShowingDetailedModalView = false
    
    @State var topRatedFilter: Category?
    @State var wineryCount = 0
    @State var breweryCount = 0
    @State var cafeCount = 0
    @State var pizzeriaCount = 0
    @State var activityCount = 0
    @State var userReviews: [Review]? {
        didSet {
            wineryCount = userReviews?.filter({$0.location.category == .Winery}).count ?? 0
            breweryCount = userReviews?.filter({$0.location.category == .Brewery}).count ?? 0
            cafeCount = userReviews?.filter({$0.location.category == .Cafe}).count ?? 0
            pizzeriaCount = userReviews?.filter({$0.location.category == .Pizzeria}).count ?? 0
            activityCount = userReviews?.filter({$0.location.category == .Activity}).count ?? 0
        }
    }
    
    let rows: [GridItem] = Array(repeating: .init(.flexible()), count: 1)
    
    var body: some View {
        ZStack {
            Color.OKGNBlue.edgesIgnoringSafeArea(.top)
            
            VStack(alignment: .leading, spacing: 0) {
                
                // Name
                HStack(alignment: .top) {
                    Text("Good Morning\nBlake")
                        .font(.title)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    // Number of venues visited
                    
                    VenuesVisitedView(showVenuesVisitedSubCategories: $isShowingVenuesVisitedSubCategories,
                                      pizzeriaCount: pizzeriaCount,
                                      wineryCount: wineryCount,
                                      breweryCount: breweryCount,
                                      cafeCount: cafeCount,
                                      activityCount: activityCount)
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 6)
                    
                }
                .padding(.horizontal)
                
                // Awards For visiting specific categories multiple times
                
                ScrollView(.horizontal) {
                    LazyHGrid(rows: rows) {
                        ProgressBar(progress: $wineryCount, award: AwardTypes.wineryAward)
                        ProgressBar(progress: $breweryCount, award: AwardTypes.breweryAward)
                        ProgressBar(progress: $pizzeriaCount, award: AwardTypes.pizzeriaAward)
                        ProgressBar(progress: $cafeCount, award: AwardTypes.cafeAward)
                        ProgressBar(progress: $activityCount, award: AwardTypes.activityAward)
                        
                    }
                }
                .frame(height: 200)
                
                // Most recent visit (Just one)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Most Recent Visit")
                        .foregroundColor(.white)
                        .font(.title2)
                        .fontWeight(.semibold)
                    if let mostRecentReview = userReviews?.sorted(by: { $0.date > $1.date }).first {
                        ReviewCell(review: mostRecentReview)
                            .onTapGesture {
                                withAnimation {
                                    isShowingDetailedModalView = true
                                }
                                
                            }
                    } else {
                        HStack {
                            
                            Spacer()
                            
                            Text("No Recent Reviews 😞")
                                .padding()
                                .background(.secondary)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .frame(alignment: .center)
                                .padding(.top)
                            
                            Spacer()
                        }
                        
                    }
                    
                        
                }
                .padding(8)
                
                // Favourites from each category
                
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
                            
                            ForEach(userReviews?.filter({topRatedFilter == nil ? $0.ranking == .first : $0.location.category == topRatedFilter && ($0.ranking == .first || $0.ranking == .second || $0.ranking == .third) }) ?? []) { review in
                                TrophyCell(review: review)
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
                
                
                Spacer()
            }
            
            if isShowingDetailedModalView {
                
                Color(.systemBackground)
                    .ignoresSafeArea(.all)
                    .opacity(0.4)
                    .transition(.opacity)
                    .animation(.easeOut, value: isShowingDetailedModalView)
                    .zIndex(1)
                
                DetailedVisitModalView(review: MockData.pizzeriaReview2, isShowingDetailedVisitView: $isShowingDetailedModalView)
                    .transition(.opacity.combined(with: .slide))
                    .animation(.easeOut, value: isShowingDetailedModalView)
                    .zIndex(2)
            }
            
            
        }
        .onAppear {
            //To do: get populate this array from network call
            userReviews = MockData.mockReviews
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}

struct VenuesVisitedView: View {
    
    @Binding var showVenuesVisitedSubCategories: Bool
    var pizzeriaCount: Int
    var wineryCount: Int
    var breweryCount: Int
    var cafeCount: Int
    var activityCount: Int
    
    var body: some View {
        
        
        VStack(alignment: .trailing, spacing: 0) {
            Text("Venues Visited: \(wineryCount + breweryCount + pizzeriaCount + cafeCount + activityCount)")
                .fontWeight(.bold)
                .padding(8)
                .background(showVenuesVisitedSubCategories ? Color.OKGNPink : Color.OKGNPurple)
                .clipShape(Capsule())
                .onTapGesture {
                    withAnimation {
                        showVenuesVisitedSubCategories.toggle()
                    }
                    
                }
                .zIndex(1)

            VStack(alignment: .trailing, spacing: 6) {
                Text("Wineries: \(wineryCount)").fontWeight(.semibold)
                Text("Breweies: \(breweryCount)").fontWeight(.semibold)
                Text("Pizzarias: \(pizzeriaCount)").fontWeight(.semibold)
                Text("Cafe's: \(cafeCount)").fontWeight(.semibold)
                Text("Activities: \(activityCount)").fontWeight(.semibold)
            }
            .frame(height: showVenuesVisitedSubCategories ? 120 : 0)
            .padding(.top, showVenuesVisitedSubCategories ? 22 : 0)
            .padding(4)
            .padding(.bottom, 4)
            .padding(.trailing, 6)
            .background(Color.OKGNPink)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .offset(y: -22)
            .zIndex(0)
        }
    }
}
