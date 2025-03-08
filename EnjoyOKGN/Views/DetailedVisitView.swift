//
//  DetailedVisitView.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-02-03.
//

import SwiftUI
import CloudKit

struct DetailedVisitModalView: View {
    
    @EnvironmentObject var reviewManager: ReviewManager
    @Environment(\.openURL) var openURL
    
    var review: OKGNReview
    @Binding var isShowingDetailedVisitView: Bool

    
    var body: some View {
        ZStack {
            
            VStack(spacing: 0) {
                
                Spacer().frame(height: 30)
                
                HStack {
                    
                    Text(review.reviewerName)
                        
                    Spacer()
                    
                    Text(review.date, formatter: DateFormatter.shortDate)
                        
                }
                .padding()
                .minimumScaleFactor(0.75)
                
                
                Text(review.locationName)
                    .foregroundColor(returnCategoryFromString(review.locationCategory).color)
                    .font(.title2)
                    .fontWeight(.bold)
                    .minimumScaleFactor(0.75)
                    .multilineTextAlignment(.center)
                
                Text(returnCategoryFromString(review.locationCategory).description)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                
                
                Image(uiImage: review.photo.convertToUIImage(in: .square))
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .scaledToFit()
                    .padding()
                
                HStack(spacing: 0) {
                    
                    if let trophy = review.ranking?.trophyImage {
                        trophy
                            .resizable()
                            .scaledToFill()
                            .frame(width: 20, height: 20)
                            .padding(.trailing)
                    }
                    
                    Text("Rating: ").bold()
                        .foregroundColor(.white)
                    Text(review.rating)
                        .foregroundColor(review.rating > "7.5" ? .green : review.rating > "5" ? .orange : .red)
                    +
                    Text( " - " + "\"" + review.reviewCaption + "\"")
                        .foregroundColor(.white)
                }
                .foregroundColor(.white)
            }
            .frame(width: 340, height: 440)
            .padding(.vertical)
            .background(VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark)))
            .cornerRadius(16)
            .overlay(
                
                HStack {
                    
                    if review.reviewerName.lowercased() == CloudKitManager.shared.profile?.convertToOKGNProfile().name.lowercased() {
                        Button {
                            deleteVisit()
                            removeFromAwards(reviewCategory: returnCategoryFromString(review.locationCategory))
                            reviewManager.userReviews.removeAll { $0.id == review.id}
                            withAnimation {
                                isShowingDetailedVisitView = false
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(returnCategoryFromString(review.locationCategory).color)
                                
                                Image(systemName: "trash")
                                    .foregroundColor(.white)
                                    .imageScale(.small)
                                    .frame(width: 44, height: 44)
                            }
                        }
                    } else {
                        Button {
                            flagVisit()
                        } label: {
                            ZStack {
                                Circle()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(returnCategoryFromString(review.locationCategory).color)
                                
                                Image(systemName: "flag.fill")
                                    .foregroundColor(.white)
                                    .imageScale(.small)
                                    .frame(width: 44, height: 44)
                            }
                            
                            
                            
                        }

                    }

                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            isShowingDetailedVisitView = false
                        }
                        
                    } label: {
                        XDismissButton(color: returnCategoryFromString(review.locationCategory).color)
                    }
                }, alignment: .top
            )
            
            if let avatar = review.reviewerAvatar?.convertToUIImage(in: .square) {
                Image(uiImage: avatar)
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 100, height: 100)
                    .scaledToFit()
                    .font(.title)
                    .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 6)
                    .offset(y: -220)
            }
        }
    }
    
    
    func deleteVisit() {
        Task {
            do {
                let _ = try await CloudKitManager.shared.deleteRecord(recordID: review.id)
            } catch {
                print("❌ Failed deleting record")
            }
        }
    }
    
    
    func flagVisit() {
        let reportEmail = EmailAddLocation(toAddress: "blakepat@me.com",
                                             subject: "Post contains inappropriate content",
                                           messageHeader: "POST: \"\(review.id.recordName)\" by user \(review.reviewerName) contains inappropriate content.")
        reportEmail.send(openURL: openURL)
    }
    
    func removeFromAwards(reviewCategory: Category) {

        print("🐤🐤 add review to total called for \(reviewCategory)")
        switch reviewCategory {
        case .Winery:
            reviewManager.eachCategoryVisitCount[0] -= 1
            print(reviewManager.eachCategoryVisitCount[0])
            if reviewManager.eachCategoryVisitCount[0] == 9 {
                removeAwardToCloudProfile(category: reviewCategory)
            }
        case .Brewery:
            reviewManager.eachCategoryVisitCount[1] -= 1
            if reviewManager.eachCategoryVisitCount[1] == 9 {
                removeAwardToCloudProfile(category: reviewCategory)
            }
        case .Cafe:
            reviewManager.eachCategoryVisitCount[2] -= 1
            if reviewManager.eachCategoryVisitCount[2] == 9 {
                removeAwardToCloudProfile(category: reviewCategory)
            }
        case .Pizzeria:
            reviewManager.eachCategoryVisitCount[3] -= 1
            if reviewManager.eachCategoryVisitCount[3] == 9 {
                removeAwardToCloudProfile(category: reviewCategory)
            }
        case .Activity:
            reviewManager.eachCategoryVisitCount[4] -= 1
            if reviewManager.eachCategoryVisitCount[4] == 9 {
                removeAwardToCloudProfile(category: reviewCategory)
            }
        }
    }
        
        
        
        func removeAwardToCloudProfile(category: Category) {
            print("⚠️⚠️⚠️ VISITS HIT 9 FOR \(category.description) REMOVING AWARD TO ICLOUD")
            Task {
                guard let userRecord = CloudKitManager.shared.userRecord else {
                    print("❌ No user record found when calling getProfile()")
                    return
                }
                
                guard let profileReference = userRecord["userProfile"] as? CKRecord.Reference else { return }
                
                let profileRecordID = profileReference.recordID
                let profileRecord = try await CloudKitManager.shared.fetchRecord(with: profileRecordID)
                
                var currentAwards = CloudKitManager.shared.profile?.convertToOKGNProfile().awards ?? []
                currentAwards.removeAll { $0 == category.description }
                
                profileRecord[OKGNProfile.kAwards] = currentAwards
                
                Task {
                    do {
                        let _ = try await CloudKitManager.shared.save(record: profileRecord)
                        print("✅✅ Success saving profile for AWARDLIST")
                    } catch let err {
                        print("❌❌ Failure saving profile for AWARDLIST: \(err)")
                    }
                    
                    
                    reviewManager.getUserReviews()
                }
            }
        }
    
    
}

struct DetailedVisitView_Previews: PreviewProvider {
    static var previews: some View {
        DetailedVisitModalView(review: MockData.pizzeriaReview1.convertToOKGNReview(), isShowingDetailedVisitView: .constant(true))
            .background(Color.OKGNDarkBlue)
    }
}


struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
