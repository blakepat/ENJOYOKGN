//
//  CreateReviewView.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-16.
//

import SwiftUI
import CloudKit

struct CreateReviewView: View {
    
    let cacheManager = CacheManager.instance
    @State var locationName: String = ""
    @State var caption: String = ""
    @State var selectedDate: Date = Date()
    @State var locations: [OKGNLocation]
    @State var firstNumber = 0
    @State var secondNumber = 0
    @State var selectedLocation: OKGNLocation?
    @State var selectedImage: UIImage = PlaceholderImage.square
    @State var alertItem: AlertItem?
    @State var isShowingPhotoPicker = false
    
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
                            .foregroundColor(returnCategoryFromString(selectedLocation?.category ?? "Activity").color)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    
                    List {
                        ForEach(categories, id: \.self) { category in
                            Section(header: Text(category.description).foregroundColor(.gray)) {
                                ForEach(locations.filter({$0.category == category.description})) { location in
                                    Button {
                                        locationName = location.name
                                        selectedLocation = location
                                    } label: {
                                        Text(location.name)
                                            .foregroundColor(.white)
                                    }
                                    .listRowBackground(VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark)))
                                }
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .frame(height: 180)
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
                            .frame(width: 120 ,height: 120)
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
                    locations = try await CloudKitManager.shared.getLocations()
                } catch {
                    print("❌ Error getting locations for create review screen")
                }
            }
        }
    }
    
    func createReview() {
        //retrieve the OKGN Profile
        
        if checkReviewIsProperlySet() {
            guard let profileRecordID = CloudKitManager.shared.profileRecordID else {
                alertItem = AlertContext.notSignedIntoProfile
                return
                
            }
            
            Task {
                do {
                    let _ = try await CloudKitManager.shared.fetchRecord(with: profileRecordID)
                    let reviewRecord = CKRecord(recordType: RecordType.review)
                    //Create a reference to the location
                    if !locations.isEmpty {
                        
                        print("trying to create record")
                        
                        reviewRecord[OKGNReview.kLocation] = CKRecord.Reference(recordID: locations.first(where: {$0.name == locationName})!.id, action: .none)
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

                    } else {
                        //To-do: show  alert that was unable to get locations
                        print("unable to get locations")
                    }
                    
                    //save review to cloudkit
                    do {
                        let _ = try await CloudKitManager.shared.batchSave(records: [reviewRecord])
                        print("✅ created review successfully")
                    } catch {
                        print("❌ failed saving review")
                    }
                } catch {
                    print("failure in fetching record review")
                }
            }
            resetReviewPage()
            alertItem = AlertContext.successfullyCreatedReview
            
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

//struct CreateReviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateReviewView(locations: [])
//    }
//}
