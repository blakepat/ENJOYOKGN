//
//  LocationListView.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-02-08.
//


import SwiftUI
import CloudKit

struct LocationListView: View {
    
    @Binding var tabSelection: TabBarItem
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    @State var locations: [OKGNLocation] {
        didSet {
            showLoadingView = false
//            LocationManager().saveLocations(locationsToSave: locations) USED TO MIGRATE DATA FROM DEVELOPMENT TO PRODUCTION
        }
    }
    @EnvironmentObject var reviewManager: ReviewManager
    @State private var isShowingFilterModal = false
    @State private var filterCategory: Category?
    @State private var filterFavourites = false
    @State private var selectedLocation: OKGNLocation? = nil
    @State private var showLocationDetailView = false
    @State private var showLoadingView = false
    @State private var searchText = ""
    @State private var showAlertView = false
    
    var searchResults: [OKGNLocation] {
        
        var locationsToReturn: [OKGNLocation] = []

       if searchText.isEmpty && filterCategory == nil && !filterFavourites {
           return locations
       } else if searchText.isEmpty {
           locationsToReturn = locations.filter({
               (filterCategory != nil ? returnCategoryFromString($0.category) == filterCategory : true)
           })
       } else {
           locationsToReturn = locations.filter({
               $0.name.contains(searchText)
               && (filterCategory != nil ? returnCategoryFromString($0.category) == filterCategory : true)
           })
       }
                
       if filterFavourites {
           let compareSet = Set(getFavouritesAsOKGNLocations())
           locationsToReturn = locationsToReturn.filter { compareSet.contains($0) }
       }
        return locationsToReturn
    }

    
    init(locations: [OKGNLocation], tabSelection: Binding<TabBarItem>) {
        self._locations = State(initialValue: locations)
        UICollectionView.appearance().backgroundColor = UIColor(named: "OKGNDarkGray")
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : UIColor.white]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor : UIColor.white]
        self._tabSelection = tabSelection
    }
    
    var body: some View {
        
        ZStack {
            Color.OKGNDarkGray.ignoresSafeArea()
            
            NavigationView {
                List {                    
                    ForEach(0..<searchResults.count, id: \.self) { locationIndex in
                        
                        let location = searchResults[locationIndex]
                        
                        HStack {
                            LocationCell(location: location)
                            Spacer()
                            }
                            .contentShape(Rectangle())
                            .listRowBackground(Color.clear)
                            .onTapGesture {
                                segue(location: location)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .searchable(text: $searchText)
                .listRowBackground(Color.clear)
                .background(
                    NavigationLink(destination: createLocationDetailView(for: selectedLocation, in: sizeCategory),
                                   isActive: $showLocationDetailView,
                                   label: { EmptyView() })
                )
                .navigationTitle("OKGN Locations")
                .listStyle(.grouped)
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            filterFavourites.toggle()
                        } label: {
                            Image(systemName: filterFavourites ? "star.fill" : "star")
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isShowingFilterModal.toggle()
                        } label: {
                            Text("Filter")
                        }
                    }
                })
            }
            .alert(AlertContext.cannotRetrieveLocations.title, isPresented: $showAlertView, actions: {
                // actions
            }, message: {
                AlertContext.cannotRetrieveLocations.message
            })
            .navigationViewStyle(StackNavigationViewStyle())
            .onChange(of: tabSelection, perform: { newValue in
                if tabSelection == .list {
                    Task {
                        if locations.isEmpty {
                            do {
                                self.showLoadingView = true
                                locations = try await CloudKitManager.shared.getLocations() { (returnedBool) in
                                    self.showLoadingView = returnedBool
                                    
                                    Task {
//                                        await LocationManager().uploadLocations() USED TO MIGRATE DATA FROM DEVELOPMENT TO PRODUCTION
                                    }
                                }
                            } catch {
                                //TO-DO: create alert
                                print("❌ unable to get locations for locationListView")
                                self.showAlertView = true
                                self.showLoadingView = false
                            }
                        
                        }
                    }
                }
            })
            
            SideMenuView(categoryFilter: $filterCategory, menuOpen: $isShowingFilterModal)
            
            
            if showLoadingView {
                GeometryReader { _ in
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            LoadingView()
                            Spacer()
                        }
                        Spacer()
                    }
                }
                .background(Color.black.opacity(0.45)).edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    //function used as Lazy Navigation Link to stop from all LocationDetailViews loading when list is created
    private func segue(location: OKGNLocation) {
        selectedLocation = location
        showLocationDetailView.toggle()
    }
    
    
    @ViewBuilder func createLocationDetailView(for location: OKGNLocation?, in sizeCategory: DynamicTypeSize) -> some View {
        if sizeCategory >= .accessibility2 {
            LocationDetailView(viewModel: LocationDetailViewModel(location: location)).embedInScrollView()
        } else {
            LocationDetailView(viewModel: LocationDetailViewModel(location: location))
        }
    }
    
    
    private func getFavouritesAsOKGNLocations() -> [OKGNLocation] {
        
        guard let favourites = CloudKitManager.shared.profile?.convertToOKGNProfile().favouriteLocations else { return [] }
        
        var favouriteLocations: [OKGNLocation] = []
        
        for location in locations {
            for favourite in favourites where location.id == favourite.recordID {
                favouriteLocations.append(location)
            }
        }
        
        return favouriteLocations
    }
}


extension UICollectionReusableView {
    override open var backgroundColor: UIColor? {
        get { .clear }
        set { }
    }
}
