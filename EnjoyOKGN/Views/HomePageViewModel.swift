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
    
    @Published var isShowingPhotoPicker = false
    @Published var profile: OKGNProfile?
    @Published var existingProfileRecord: CKRecord? {
        didSet {
            profileContext = .update
            print("✅ Existing profile set and context changed to .update!")
        }
    }
    @Published var profileContext: ProfileContext = .create
    
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
        
        Task {
            do {
                let records = try await CloudKitManager.shared.batchSave(records: [userRecord, profileRecord])
                for record in records where record.recordType == RecordType.profile {
                    self.existingProfileRecord = record
                    CloudKitManager.shared.profileRecordID = record.recordID
                }
            } catch {
                self.alertItem = AlertContext.profileCreateFailure
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
        
        Task {
            do {
                let profileRecordID = profileReference.recordID
                let record = try await CloudKitManager.shared.fetchRecord(with: profileRecordID)
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
            } catch {
                print(error)
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
        
        Task {
            do {
                let _ = try await CloudKitManager.shared.save(record: profileRecord)
                alertItem = AlertContext.profileUpdateSuccess
            } catch {
                alertItem = AlertContext.profileUpdateFailure
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
