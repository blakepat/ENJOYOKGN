//
//  HomePageView.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-01-21.
//

import SwiftUI

struct HomePageView: View {
    
    @State var showVenuesVisitedSubCategories = false
    @State var progressValue: Float = 0.20
    
    let rows: [GridItem] = Array(repeating: .init(.flexible()), count: 1)
    
    var body: some View {
        ZStack {
            Color.OKGNBlue.edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 0) {
                
                // Name
                HStack(alignment: .top) {
                    Text("Good Morning\nBlake")
                        .font(.title)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    // Number of venues visited
                    
                    VenuesVisitedView(showVenuesVisitedSubCategories: $showVenuesVisitedSubCategories)
                    
                }
                .padding(.horizontal)
                
                // Awards For visiting specific categories multiple times
                
                ScrollView(.horizontal) {
                    LazyHGrid(rows: rows) {
                        ForEach((0...4), id: \.self) { index in
                            ProgressBar(progress: self.$progressValue, award: AwardTypes.awards[index])
                        }
                    }
                }
                .frame(height: 200)
                
                // Most recent visit (Just one)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Most Recent Visit")
                        .foregroundColor(.white)
                        .font(.title2)
                        .fontWeight(.semibold)
                    ReviewCell(user: MockData.mockUser, location: MockData.mockPizzeriaLocation, height: 160)
                        
                }
                .padding(8)
                
                // Favourites from each category
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Top Rated Visits:")
                        .foregroundColor(.white)
                        .font(.title2)
                        .fontWeight(.semibold)
                    .padding(.top)
                    
                    ScrollView(.vertical) {
                        LazyVGrid(columns: rows) {
                            ForEach(MockData.mockReviews) { review in
                                TrophyCell(review: review)
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
                
               
                
                
                
                
                
                Spacer()
            }
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
    
    var body: some View {
        
        
        VStack(alignment: .trailing, spacing: 0) {
            Text("Venues Visited: 33")
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
                Text("Cafe's: 6").fontWeight(.semibold)
                Text("Wineries: 12").fontWeight(.semibold)
                Text("Breweies: 5").fontWeight(.semibold)
                Text("Pizzarias: 5").fontWeight(.semibold)
                Text("Activities: 4").fontWeight(.semibold)
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
