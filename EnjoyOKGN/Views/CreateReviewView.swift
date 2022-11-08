//
//  CreateReviewView.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-16.
//

import SwiftUI
import CloudKit

struct CreateReviewView: View {
    
    @EnvironmentObject var reviewManager: ReviewManager
    @EnvironmentObject var locationManager: LocationManager
    @ObservedObject var viewModel = CreateReviewViewModel()
    
    let cacheManager = CacheManager.instance
    
    @State var selectedDate: Date = Date()
    @State var locations: [OKGNLocation]
    @Binding var tabSelection: TabBarItem
    
    init(date: Date, locations: [OKGNLocation], tabSelection: Binding<TabBarItem>) {
        UITableView.appearance().backgroundColor = UIColor(white: 0.35, alpha: 0.3)
        UITextView.appearance().backgroundColor = .clear
        self._selectedDate = State(initialValue: date)
        self._locations = State(initialValue: locations)
        self._tabSelection = tabSelection
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            
            Color.OKGNDarkBlue.edgesIgnoringSafeArea(.all)
            
            VStack {
                
                createReviewTitle
                
                reviewDateSelector
                
                reviewLocationSelector
                
                reviewCaption
                
                reviewRatingSelector
      
                reviewPhotoPicker
                
                createReviewButton
                
                Spacer()
            }
            .alert(viewModel.alertItem?.title ?? Text(""), isPresented: $viewModel.showAlertView, actions: {
                // actions
            }, message: {
                viewModel.alertItem?.message ?? Text("")
            })
            .frame(maxHeight: .infinity)
            .padding(.bottom)
            .background(LinearGradient(gradient: Gradient(colors: [.OKGNDarkBlue, .black.opacity(0.5)]), startPoint: .top, endPoint: .bottom))
            .sheet(isPresented: $viewModel.isShowingPhotoPicker, content: {
                PhotoPicker(image: $viewModel.selectedImage)
            })
            .onReceive(locationManager.$locationNamesIdsCategory) { locationNamesIds in
                viewModel.locationNamesIdsCategory = locationNamesIds
            }
            .onChange(of: tabSelection) { newValue in
                
                if newValue == .create {
                    Task {
                        if locationManager.locationNamesIdsCategory.isEmpty {
                            do {
                                viewModel.showLoadingView = true
                                locationManager.locationNamesIdsCategory = try await CloudKitManager.shared.getLocationNames() { returnedBool in
                                    DispatchQueue.main.async {
                                        viewModel.locationNamesIdsCategory = locationManager.locationNamesIdsCategory
                                        viewModel.showLoadingView = returnedBool
                                    }
                                }
                            } catch {
                                print("❌ Error getting locations for create review screen")
                            }
                        }
                    }
                }
            }
            if viewModel.showLoadingView {
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
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    
    func createReview() {
        CKContainer.default().accountStatus { (accountStatus, error) in
            if accountStatus == .available {
                if checkReviewIsProperlySet()  {
                    guard let profileRecordID = CloudKitManager.shared.profileRecordID else {
                        DispatchQueue.main.async {
                            viewModel.alertItem = AlertContext.notSignedIntoProfile
                            viewModel.showAlertView = true
                        }
                        
                        return
                    }
                    
                    Task {
                        do {
                            let reviewRecord = CKRecord(recordType: RecordType.review)
                            
                            let profileRecord = try await CloudKitManager.shared.fetchRecord(with: profileRecordID)
                            DispatchQueue.main.async { [self] in
                                print("✅ success getting profile")
                                
                                CloudKitManager.shared.profile = profileRecord
                                let importedProfile = OKGNProfile(record: profileRecord)
                                cacheManager.addAvatarToCache(avatar: importedProfile.createProfileImage())
                                cacheManager.addNameToCache(name: importedProfile.name)
                            }
                            //Create a reference to the location
                            if !locationManager.locationNamesIdsCategory.isEmpty {
                                
                                print("trying to create record")
                                
                                if let selectedLocationId = viewModel.selectedLocationId {
                                    reviewRecord[OKGNReview.kLocation] = CKRecord.Reference(recordID: selectedLocationId, action: .none)
                                    //create a rereference to profile
                                    reviewRecord[OKGNReview.kReviewer] = CKRecord.Reference(recordID: profileRecordID, action: .none)
                                    reviewRecord[OKGNReview.kCaption] = viewModel.caption
                                    reviewRecord[OKGNReview.kPhoto] = viewModel.selectedImage.convertToCKAsset(path: "selectedPhoto")
                                    reviewRecord[OKGNReview.kRating] = "\(viewModel.firstNumber).\(viewModel.secondNumber)"
                                    reviewRecord[OKGNReview.kDate] = selectedDate
                                    reviewRecord[OKGNReview.klocationName] = viewModel.locationName
                                    reviewRecord[OKGNReview.klocationCategory] = viewModel.selectedLocationCategory
                                    print("🐤\(viewModel.selectedLocationCategory ?? "")")
                                    reviewRecord[OKGNReview.kReviewerName] = cacheManager.getNameFromCache()
                                    reviewRecord[OKGNReview.kReviewerAvatar] = cacheManager.getAvatarFromCache()?.convertToCKAsset(path: "profileAvatar")
                                }
                            } else {
                                print("❌❌ unable to get locations")
                                DispatchQueue.main.async {
                                    viewModel.alertItem = AlertContext.reviewCreationFailed
                                    viewModel.showAlertView = true
                                }
                                
                                return
                            }
                            do {
                                
                                if let _ = try await CloudKitManager.shared.batchSave(records: [reviewRecord]) {
                                    
                                    addNewReviewToTotals(reviewCategory: returnCategoryFromString(viewModel.selectedLocationCategory ?? ""))
                                    DispatchQueue.main.async {
                                        viewModel.alertItem = AlertContext.successfullyCreatedReview
                                        viewModel.showAlertView = true
                                    }
                                    
                                    print("✅ created review successfully")
                                    resetReviewPage()
                                    
                                    
                                    
                                    
                                } else {
                                    viewModel.alertItem = AlertContext.reviewCreationFailed
                                    viewModel.showAlertView = true
                                }
                                
                            } catch {
                                print("❌ failed saving review")
                            }
                        } catch {
                            print("failure in fetching record review")
                        }
                    }
                }
            } else {
                print("⚠️ Error creating review / checking icloud status")
                DispatchQueue.main.async {
                    viewModel.alertItem = AlertContext.reviewCreationFailed
                    viewModel.showAlertView = true
                }
            }
        }
    }
    
    
    func addNewReviewToTotals(reviewCategory: Category) {
        print("🐤🐤 add review to total called for \(reviewCategory)")
        switch reviewCategory {
        case .Winery:
            reviewManager.eachCategoryVisitCount[0] += 1
            print(reviewManager.eachCategoryVisitCount[0])
            if reviewManager.eachCategoryVisitCount[0] == 10 {
                addAwardToCloudProfile(category: reviewCategory)
            }
        case .Brewery:
            reviewManager.eachCategoryVisitCount[1] += 1
            if reviewManager.eachCategoryVisitCount[1] == 10 {
                addAwardToCloudProfile(category: reviewCategory)
            }
        case .Cafe:
            reviewManager.eachCategoryVisitCount[2] += 1
            if reviewManager.eachCategoryVisitCount[2] == 10 {
                addAwardToCloudProfile(category: reviewCategory)
            }
        case .Pizzeria:
            reviewManager.eachCategoryVisitCount[3] += 1
            if reviewManager.eachCategoryVisitCount[3] == 10 {
                addAwardToCloudProfile(category: reviewCategory)
            }
        case .Activity:
            reviewManager.eachCategoryVisitCount[4] += 1
            if reviewManager.eachCategoryVisitCount[4] == 10 {
                addAwardToCloudProfile(category: reviewCategory)
            }
        }
    }
    
    func addAwardToCloudProfile(category: Category) {
        print("⚠️⚠️⚠️ VISITS HIT 10 FOR \(category.description) ADDING AWARD TO ICLOUD")
        Task {
            guard let userRecord = CloudKitManager.shared.userRecord else {
                print("❌ No user record found when calling getProfile()")
                return
            }
            
            guard let profileReference = userRecord["userProfile"] as? CKRecord.Reference else { return }
            
            let profileRecordID = profileReference.recordID
            let profileRecord = try await CloudKitManager.shared.fetchRecord(with: profileRecordID)
            
            var currentAwards = CloudKitManager.shared.profile?.convertToOKGNProfile().awards ?? []
            currentAwards += [category.description]
            
            profileRecord[OKGNProfile.kAwards] = currentAwards
            
            Task {
                do {
                    let _ = try await CloudKitManager.shared.save(record: profileRecord)
                    print("✅✅ Success saving profile for AWARDLIST")
                } catch let err {
                    print("❌❌ Failure saving profile for AWARDLIST: \(err)")
                }
            }
        }
    }
    
    
    func resetReviewPage() {
        viewModel.locationName = ""
        viewModel.caption = ""
        viewModel.firstNumber = 0
        viewModel.secondNumber = 0
        viewModel.selectedImage = PlaceholderImage.square
        selectedDate = Date()
    }
    
    
    func checkReviewIsProperlySet() -> Bool {
        if (viewModel.locationName != "" && viewModel.caption != "" && viewModel.firstNumber + viewModel.secondNumber != 0) && !(viewModel.firstNumber == 10 && viewModel.secondNumber > 0) {
            return true
        } else {
            DispatchQueue.main.async {
                viewModel.alertItem = AlertContext.reviewImproperlyFilledOut
                viewModel.showAlertView = true
            }
            return false
        }
    }
}
    
    

extension CreateReviewView {
    
    
    private var createReviewTitle: some View {
        HStack {
            Text("Create Review")
                .bold()
                .font(.title)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    
    private var reviewDateSelector: some View {
        HStack {
            DatePicker("", selection: $selectedDate)
                .padding(.leading, 4)
                .datePickerStyle(CompactDatePickerStyle())
                .frame(width: screen.width / 2, height: 30, alignment: .leading)
                .colorScheme(.dark)
            
            Spacer()
        }
    }
    
    
    private var reviewLocationSelector: some View {
        VStack {
            HStack(spacing: 0) {
                Text("Location: ")
                    .bold()
                    .font(.callout)
                    .foregroundColor(.white)
                
                Text(viewModel.locationName)
                    .font(.callout)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .foregroundColor(returnCategoryFromString(viewModel.selectedLocationCategory ?? "Activity").color)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            
            List {
                ForEach(locationManager.locationNamesIdsCategory, id: \.0) { location in
                    Button {
                        viewModel.locationName = location.1
                        viewModel.selectedLocationId = location.0
                        viewModel.selectedLocationCategory = location.2
                    } label: {
                        Text(location.1)
                            .foregroundColor(.white)
                            .onTapGesture {
                                viewModel.locationName = location.1
                                viewModel.selectedLocationId = location.0
                                viewModel.selectedLocationCategory = location.2
                            }
                    }
                    .listRowBackground(VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark)))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .frame(height: screen.height / 3 - 100)
            .padding(.horizontal, 16)
        }
    }
    
    
    private var reviewCaption: some View {
        VStack {
            HStack {
                Text("Caption: ")
                    .bold()
                    .font(.callout)
                    .foregroundColor(.white)
                    +
                Text("\(20 - viewModel.caption.count)")
                    .bold()
                    .font(.callout)
                    .foregroundColor(viewModel.caption.count <= 20 ? .OKGNDarkYellow : Color(.systemPink))
                    +
                Text(" Characters Remain")
                    .font(.callout)
                    .foregroundColor(.gray)
                
                Spacer()
                
            }
            
            TextEditor(text: $viewModel.caption)
                .frame(height: 50)
                .foregroundColor(.white)
                .overlay { RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1) }
                .accessibilityHint(Text("Summerize your experience in a fun and short way. (20 character maximum"))
                .background(Color(white: 0.35, opacity: 0.3))
                
        }
        .padding(.horizontal, 16)
    }
    
    
    private var reviewRatingSelector: some View {
        VStack {
            HStack {
                Text("Rating: ")
                    .bold()
                    .font(.callout)
                    .foregroundColor(.white)
                Text((viewModel.firstNumber > 0 || viewModel.secondNumber > 0) && !(viewModel.firstNumber == 10 && viewModel.secondNumber > 0) ? "\(viewModel.firstNumber).\(viewModel.secondNumber)" : "Rate experience from 0.1 to 10.0")
                    .font(.callout)
                    .foregroundColor((viewModel.firstNumber > 0 || viewModel.secondNumber > 0) && !(viewModel.firstNumber == 10 && viewModel.secondNumber > 0) ? (viewModel.firstNumber > 5 ? (viewModel.firstNumber > 7 ? .OKGNLightGreen : .OKGNDarkYellow) : Color(.systemPink)) : .gray)
                
                Spacer()
            }
            
            GeometryReader { geometry in
                HStack {
                    Picker(selection: self.$viewModel.firstNumber, label: Text("")) {
                        ForEach(0...10, id: \.self) { index in
                            Text("\(index)").tag(index)
                                .foregroundColor(.white)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: geometry.size.width / 2, height: 80, alignment: .center)
                    .compositingGroup()
                    .clipped()
                    
                    Picker(selection: self.$viewModel.secondNumber, label: Text("")) {
                        ForEach(0...9, id: \.self) { index in
                            Text("\(index)").tag(index)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: geometry.size.width / 2, height: 80, alignment: .center)
                    .pickerStyle(.wheel)
                    .compositingGroup()
                    .clipped()
                }
            }
            .frame(height: 100)
        }
        .padding(.horizontal, 16)
    }
    
    
    private var reviewPhotoPicker: some View {
        VStack {
            HStack {
                Text("Photo:")
                    .bold()
                    .font(.callout)
                    .foregroundColor(.white)
                
                Text("Select a photo to remember your visit!")
                    .font(.callout)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            
            HStack {
                Image(uiImage: viewModel.selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80 ,height: 80)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .onTapGesture {
                        viewModel.isShowingPhotoPicker = true
                    }
                
                Spacer()
            }
            
        }
        .padding(.horizontal, 16)
        .padding(.bottom)
    }
    
    
    
    private var createReviewButton: some View {
        Button {
            createReview()
        } label: {
            Text("Create Review")
                .foregroundColor(.black)
                .frame(width: 260, height: 40)
                .background(Color.OKGNDarkYellow)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    
}





//OLD CODE FOR ADDING RANKING ON REVIEW CREATION
    
//    func setRankingForReview(id: CKRecord.ID, categoryName: String) async -> String {
//        
//        let reviews = reviewManager.userReviews.filter({ $0.locationCategory == categoryName }).sorted() { $0.rating > $1.rating }
//        
//        if id == reviews.first?.id {
//            print("RANK = 1")
//            let _ = await adjustRankingsForPlace(1, reviews: reviews)
//            return "1"
//            
//        } else if id == reviews.dropFirst().first?.id {
//            print("RANK = 2")
//            return "2"
//        } else if id == reviews.dropFirst(2).first?.id {
//            print("RANK = 3")
//            return "3"
//        } else {
//            print("RANK = 0")
//            return "0"
//        }
//    }
//    
//    
//    //create func to change other rankings when new one is created
//    func adjustRankingsForPlace(_ rank: Int, reviews: [OKGNReview]) async {
//        if rank == 1 {
//            Task {
//                print("💜 Adjust called!")
//                if let id = reviewManager.userReviews.dropFirst().first?.id {
//                    print("ID FOR RANKING TO CHANGE SET")
//                    let reviewToChange = try await CloudKitManager.shared.fetchRecord(with: id)
//                    reviewToChange[OKGNReview.kRanking] = "2"
//                    print(reviewToChange)
//                    //save review to cloudkit
//                    do {
//                        if let _ = try await CloudKitManager.shared.batchSave(records: [reviewToChange]) {
//
//                        } else {
//                            alertItem = AlertContext.reviewCreationFailed
//                        }
//                    } catch {
//                        print("❌ failed editing review ranking")
//                    }
//                }
//            }
//        }
//    }


//struct CreateReviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateReviewView(locations: [])
//    }
//}
