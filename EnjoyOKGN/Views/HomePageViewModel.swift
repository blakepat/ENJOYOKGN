//
//  HomePageViewModel.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-14.
//

import CloudKit
import SwiftUI

enum ProfileContext { case create, update }

final class HomePageViewModel: ObservableObject {
    
    let cacheManager = CacheManager.instance
    
    @ObservedObject var profileManager = ProfileManager()
//    init(profileManager: ProfileManager) {
//        self.profileManager = profileManager
//    }
    
    let rows: [GridItem] = Array(repeating: .init(.flexible()), count: 1)
    
    @Published var isShowingPhotoPicker = false
    @Published var profile: OKGNProfile?
    var existingProfileRecord: CKRecord? {
        didSet {
            profileContext = .update
            print("😎 Profile Context changed to update")
        }
    }
    var profileContext: ProfileContext = .create
    
    @Published var isShowingVenuesVisitedSubCategories = false
    @Published var isShowingTopRatedFilterAlert = false
    @Published var isShowingDetailedModalView = false
    @Published var isShowingSaveAlert = false
    
    @Published var detailedReviewToShow: OKGNReview?
    @Published var alertItem: AlertItem?
    @Published var topRatedFilter: Category?
    @Published var wineryCount = 0
    @Published var breweryCount = 0
    @Published var cafeCount = 0
    @Published var pizzeriaCount = 0
    @Published var activityCount = 0
    @Published var userReviews: [OKGNReview]? {
        didSet {
            wineryCount = userReviews?.filter({returnCategoryFromString($0.locationCategory) == .Winery}).count ?? 0
            breweryCount = userReviews?.filter({returnCategoryFromString($0.locationCategory) == .Brewery}).count ?? 0
            cafeCount = userReviews?.filter({returnCategoryFromString($0.locationCategory) == .Cafe}).count ?? 0
            pizzeriaCount = userReviews?.filter({returnCategoryFromString($0.locationCategory) == .Pizzeria}).count ?? 0
            activityCount = userReviews?.filter({returnCategoryFromString($0.locationCategory) == .Activity}).count ?? 0
            print("🥳 \(userReviews?.count ?? 0) User Reviews set for HomePageModel")
        }
    }

    func createProfile() {
        //Create our CKRecord from the profile view
        let profileRecord = createProfileRecord()
        
        guard let userRecord = CloudKitManager.shared.userRecord else {
            // show an alert
            self.alertItem = AlertContext.profileCreateFailure
            return
        }
        
        userRecord["userProfile"] = CKRecord.Reference(recordID: profileRecord.recordID, action: .none)
        
        CloudKitManager.shared.batchSave(records: [userRecord, profileRecord]) { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let records):
                    for record in records where record.recordType == RecordType.profile {
                        self.existingProfileRecord = record
                        CloudKitManager.shared.profileRecordID = record.recordID
                    }
                    case .failure(_):
                    self.alertItem = AlertContext.profileCreateFailure
                }
            }
        }
    }
    
    
    func getProfile() {
        guard let userRecord = CloudKitManager.shared.userRecord else {
            // show an alert
            print("❌ No user record found when calling getProfile()")
            return
        }
        
        guard let profileReference = userRecord["userProfile"] as? CKRecord.Reference else {
            return
        }
        
        let profileRecordID = profileReference.recordID
        CloudKitManager.shared.fetchRecord(with: profileRecordID) { result in
            switch result {
            case .success(let record):
                DispatchQueue.main.async { [self] in
                    print("✅ success getting profile")
                    existingProfileRecord = record
                    CloudKitManager.shared.profile = record
                    let importedProfile = OKGNProfile(record: record)
                    profile = importedProfile
                    profileManager.name = importedProfile.name
                    profileManager.avatar = importedProfile.createProfileImage()
                    cacheManager.addAvatarToCache(avatar: importedProfile.createProfileImage())
                    cacheManager.addNameToCache(name: importedProfile.name)
                    
                }
            case .failure(_):
                //show alert
                break
                
            }
        }
    }
    
    func updateProfile() {
        guard let profileRecord = existingProfileRecord else {
            //TO-DO: create alert for unable to get profile
            return
        }
        
        profileRecord[OKGNProfile.kName] = profileManager.name
        profileRecord[OKGNProfile.kAvatar] = profileManager.avatar.convertToCKAsset(path: "profileAvatar")
        cacheManager.addNameToCache(name: profileManager.name)
        cacheManager.addAvatarToCache(avatar: profileManager.avatar)
        
        CloudKitManager.shared.save(record: profileRecord) { result in
            DispatchQueue.main.async { [self] in
                switch result {
                case .success(_):
                    alertItem = AlertContext.profileUpdateSuccess
                case .failure(_):
                    //TO-DO: show alert that was unable to update profile
                    alertItem = AlertContext.profileUpdateFailure
                }
            }
        }
    }
    
    
    private func createProfileRecord() -> CKRecord {
        let profileRecord = CKRecord(recordType: RecordType.profile)
        profileRecord[OKGNProfile.kName] = profileManager.name
        profileRecord[OKGNProfile.kAvatar] = profileManager.avatar.convertToCKAsset(path: "profileAvatar")
        
        return profileRecord
        
    }
    
    
    func changeNameAlertView() {
        let alert = UIAlertController(title: "Name Editor", message: "Create display name that is 20 characters or less", preferredStyle: .alert)
        alert.addTextField { (nameForm) in
            nameForm.placeholder = "name..."
            nameForm.autocorrectionType = .no
        }
        
        let save = UIAlertAction(title: "Save", style: .default) { [self] save in
            
            if alert.textFields![0].text?.count ?? 0 > 0 && alert.textFields![0].text?.count ?? 21 < 21 {
                profileManager.name = alert.textFields![0].text!
                existingProfileRecord == nil ? print("•Profile CREATED") : print("😍Profile UPDATED")
                profileContext == .create ? createProfile() : updateProfile()
                isShowingSaveAlert = false
                cacheManager.addNameToCache(name: alert.textFields![0].text!)
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.isShowingSaveAlert = false
        }
        
        alert.addAction(save)
        alert.addAction(cancel)
        
        let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first
        
        keyWindow?.rootViewController?.present(alert, animated: true) {
            
        }
    }
}
