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
    
    let cacheManager = CacheManager.instance
    @State var locationName: String = ""
    @State var caption: String = ""
    @State var selectedDate: Date = Date()
    @State var locations: [OKGNLocation]
    @State var locationNamesIdsCategory = [(CKRecord.ID, String, String)]()
    @State var firstNumber = 0
    @State var secondNumber = 0
    @State var selectedLocation: OKGNLocation?
    @State var selectedLocationId: CKRecord.ID?
    @State var selectedLocationCategory: String?
    @State var selectedImage: UIImage = PlaceholderImage.square
    @State var alertItem: AlertItem?
    @State var isShowingPhotoPicker = false
    @State var showLoadingView = false
    
    init(date: Date, locations: [OKGNLocation]) {
        UITableView.appearance().backgroundColor = UIColor(white: 0.35, alpha: 0.3)
        UITextView.appearance().backgroundColor = .clear
        self._selectedDate = State(initialValue: date)
        self._locations = State(initialValue: locations)
    }
    
    var body: some View {
        ZStack {
            
            Color.OKGNDarkBlue.edgesIgnoringSafeArea(.all)
            
            VStack {
                
                HStack {
                    Text("Create Review")
                        .bold()
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                HStack {
                    DatePicker("", selection: $selectedDate)
                        .padding(.leading, 4)
                        .datePickerStyle(CompactDatePickerStyle())
                        .frame(width: screen.width / 2, height: 30, alignment: .leading)
                        .colorScheme(.dark)
                    
                    Spacer()
                }
                
                VStack {
                    HStack(spacing: 0) {
                        Text("Location: ")
                            .bold()
                            .font(.callout)
                            .foregroundColor(.white)
                        
                        Text(locationName)
                            .font(.callout)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .foregroundColor(returnCategoryFromString(selectedLocationCategory ?? "Activity").color)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    
                    List {                        
                        ForEach(locationNamesIdsCategory, id: \.0) { location in
                            Button {
                                locationName = location.1
                                selectedLocationId = location.0
                                selectedLocationCategory = location.2
                            } label: {
                                Text(location.1)
                                    .foregroundColor(.white)
                                    .onTapGesture {
                                        locationName = location.1
                                        selectedLocationId = location.0
                                        selectedLocationCategory = location.2
                                    }
                            }
                            .listRowBackground(VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark)))
                        }
                        
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .frame(height: 140)
                    .padding(.horizontal, 16)
                }
                
                VStack {
                    HStack {
                        Text("Caption: ")
                            .bold()
                            .font(.callout)
                            .foregroundColor(.white)
                            +
                        Text("\(20 - caption.count)")
                            .bold()
                            .font(.callout)
                            .foregroundColor(caption.count <= 20 ? .OKGNDarkYellow : Color(.systemPink))
                            +
                        Text(" Characters Remain")
                            .font(.callout)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                    }
                    
                    TextEditor(text: $caption)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .overlay { RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1) }
                        .accessibilityHint(Text("Summerize your experience in a fun and short way. (20 character maximum"))
                        .background(Color(white: 0.35, opacity: 0.3))
                        
                }
                .padding(.horizontal, 16)
                
                VStack {
                    HStack {
                        Text("Rating: ")
                            .bold()
                            .font(.callout)
                            .foregroundColor(.white)
                        Text((firstNumber > 0 || secondNumber > 0) && !(firstNumber == 10 && secondNumber > 0) ? "\(firstNumber).\(secondNumber)" : "Rate experience from 0.1 to 10.0")
                            .font(.callout)
                            .foregroundColor((firstNumber > 0 || secondNumber > 0) && !(firstNumber == 10 && secondNumber > 0) ? (firstNumber > 5 ? (firstNumber > 7 ? .OKGNLightGreen : .OKGNDarkYellow) : Color(.systemPink)) : .gray)
                        
                        Spacer()
                    }
                    
                    GeometryReader { geometry in
                        HStack {
                            Picker(selection: self.$firstNumber, label: Text("")) {
                                ForEach(0...10, id: \.self) { index in
                                    Text("\(index)").tag(index)
                                        .foregroundColor(.white)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: geometry.size.width / 2, height: 80, alignment: .center)
                            .compositingGroup()
                            .clipped()
                            
                            Picker(selection: self.$secondNumber, label: Text("")) {
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
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80 ,height: 80)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .onTapGesture {
                                isShowingPhotoPicker = true
                            }
                        
                        Spacer()
                    }
                    
                }
                .padding(.horizontal, 16)
                .padding(.bottom)
                
                Spacer()
                
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
            .padding(.bottom)
            .background(LinearGradient(gradient: Gradient(colors: [.OKGNDarkBlue, .black.opacity(0.5)]), startPoint: .top, endPoint: .bottom))
            .alert(item: $alertItem, content: { alertItem in
                Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
            })
            .sheet(isPresented: $isShowingPhotoPicker, content: {
                PhotoPicker(image: $selectedImage)
            })
            .task {
                do {
                    showLoadingView = true
                    locationNamesIdsCategory = try await CloudKitManager.shared.getLocationNames() { returnedBool in
                        showLoadingView = returnedBool
                    }
                } catch {
                    print("❌ Error getting locations for create review screen")
                }
            }
            
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
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    func createReview() {
        CKContainer.default().accountStatus { (accountStatus, error) in
            if accountStatus == .available {
                if checkReviewIsProperlySet()  {
                    guard let profileRecordID = CloudKitManager.shared.profileRecordID else {
                        alertItem = AlertContext.notSignedIntoProfile
                        return
                    }
                    
                    Task {
                        do {
                            let reviewRecord = CKRecord(recordType: RecordType.review)
                            
                            let record = try await CloudKitManager.shared.fetchRecord(with: profileRecordID)
                            DispatchQueue.main.async { [self] in
                                print("✅ success getting profile")
                                
                                CloudKitManager.shared.profile = record
                                let importedProfile = OKGNProfile(record: record)
                                cacheManager.addAvatarToCache(avatar: importedProfile.createProfileImage())
                                cacheManager.addNameToCache(name: importedProfile.name)
                            }
                            //Create a reference to the location
                            if !locationNamesIdsCategory.isEmpty {
                                
                                print("trying to create record")
                                
                                if let selectedLocationId = selectedLocationId {
                                    reviewRecord[OKGNReview.kLocation] = CKRecord.Reference(recordID: selectedLocationId, action: .none)
                                    //create a rereference to profile
                                    reviewRecord[OKGNReview.kReviewer] = CKRecord.Reference(recordID: profileRecordID, action: .none)
                                    reviewRecord[OKGNReview.kCaption] = caption
                                    reviewRecord[OKGNReview.kPhoto] = selectedImage.convertToCKAsset(path: "selectedPhoto")
                                    reviewRecord[OKGNReview.kRating] = "\(firstNumber).\(secondNumber)"
                                    reviewRecord[OKGNReview.kDate] = selectedDate
                                    reviewRecord[OKGNReview.klocationName] = locationName
                                    reviewRecord[OKGNReview.klocationCategory] = selectedLocation?.category.description
                                    reviewRecord[OKGNReview.kReviewerName] = cacheManager.getNameFromCache()
                                    reviewRecord[OKGNReview.kReviewerAvatar] = cacheManager.getAvatarFromCache()?.convertToCKAsset(path: "profileAvatar")
                                }
                            } else {
                                print("unable to get locations")
                            }
                            do {
                                
                                if let _ = try await CloudKitManager.shared.batchSave(records: [reviewRecord]) {
                                    print("✅ created review successfully")
                                    resetReviewPage()
                                    alertItem = AlertContext.successfullyCreatedReview
                                } else {
                                    alertItem = AlertContext.reviewCreationFailed
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
                alertItem = AlertContext.reviewCreationFailed
            }
        }
    }
    
    
    func resetReviewPage() {
        locationName = ""
        caption = ""
        firstNumber = 0
        secondNumber = 0
        selectedImage = PlaceholderImage.square
        selectedDate = Date()
    }
    
    func checkReviewIsProperlySet() -> Bool {
        if (locationName != "" && caption != "" && firstNumber + secondNumber != 0) && !(firstNumber == 10 && secondNumber > 0) {
            return true
        } else {
            alertItem = AlertContext.reviewImproperlyFilledOut
            return false
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
