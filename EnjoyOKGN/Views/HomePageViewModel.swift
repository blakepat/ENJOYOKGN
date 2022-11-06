//
//  HomePageViewModel.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-14.
//

import CloudKit
import SwiftUI
import MapKit

enum ProfileContext { case create, update }

final class HomePageViewModel: ObservableObject {
    
    let cacheManager = CacheManager.instance
    
    @ObservedObject var profileManager = ProfileManager()
    @EnvironmentObject var reviewManager: ReviewManager
    
    @Published var isShowingPhotoPicker = false
    @Published var profile: OKGNProfile? {
        willSet {
            Task {
                await subscribeToNotifications(profile: newValue!)
            }
            
        }
    }
    @Published var existingProfileRecord: CKRecord? {
        didSet {
            profileContext = .update
            print("✅ Existing profile set and context changed to .update!")
        }
    }
    
    @State var usernameIsValid = false
    @State var usernameText = ""
    
    //carousel variables
    @Published var currentIndex: Int = 0
    @Published var category: Category?
    
    @Published var profileContext: ProfileContext = .create
    
    @Published var isShowingVenuesVisitedSubCategories = false
    @Published var isShowingTopRatedFilterAlert = false
    @Published var isShowingDetailedModalView = false
    @Published var isShowingSaveAlert = false
    @Published var showSettingsView = false
    
    @Published var detailedReviewToShow: OKGNReview?
    @Published var alertItem: AlertItem?
    @Published var topRatedFilter: Category?
    @Published var userReviews: [OKGNReview]?
    
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
                if let records = try await CloudKitManager.shared.batchSave(records: [userRecord, profileRecord]) {
                    for record in records where record.recordType == RecordType.profile {
                        self.existingProfileRecord = record
                        CloudKitManager.shared.profileRecordID = record.recordID
                    }
                }
            } catch {
                self.alertItem = AlertContext.profileCreateFailure
            }
        }
    }
    
    
    func getProfile() {
            
        Task {
            do {
                
                guard let userRecord = CloudKitManager.shared.userRecord else {
                    print("❌ No user record found when calling getProfile()")
                    return
                }
                
                guard let profileReference = userRecord["userProfile"] as? CKRecord.Reference else { return }
                
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
            return
        }
        
        profileRecord[OKGNProfile.kName] = profileManager.name
        profileRecord[OKGNProfile.kAvatar] = profileManager.avatar.convertToCKAsset(path: "profileAvatar")
        cacheManager.addNameToCache(name: profileManager.name)
        cacheManager.addAvatarToCache(avatar: profileManager.avatar)
        
        updateProfileForReviews(avatar: profileManager.avatar, name: profileManager.name)
        
        Task {
            do {
                let _ = try await CloudKitManager.shared.save(record: profileRecord)
                alertItem = AlertContext.profileUpdateSuccess
            } catch {
                alertItem = AlertContext.profileUpdateFailure
            }
        }
    }
    
    
    func updateProfileForReviews(avatar: UIImage, name: String) {
        guard let id = CloudKitManager.shared.profileRecordID else { return }
        
        Task {
            let reviewsToUpdate = try await CloudKitManager.shared.getUserReviewsForProfileUpdate(for: id)
            
            for review in reviewsToUpdate {
                review[OKGNReview.kReviewerAvatar] = avatar.convertToCKAsset(path: "profileAvatar")
                review[OKGNReview.kReviewerName] = name
            }
           let _ = try await CloudKitManager.shared.batchSave(records: reviewsToUpdate)
        }
    }
    
    
    private func createProfileRecord() -> CKRecord {
        let profileRecord = CKRecord(recordType: RecordType.profile)
        profileRecord[OKGNProfile.kName] = profileManager.name
        profileRecord[OKGNProfile.kAvatar] = profileManager.avatar.convertToCKAsset(path: "profileAvatar")
        
        return profileRecord
        
    }
    
    
    func changeNameAlertView() {
        let alert = UIAlertController(title: "Name Editor", message: "Create display name that is between 3 and 20 characters \n(no special characters)", preferredStyle: .alert)
        alert.addTextField { (nameForm) in
            nameForm.placeholder = "new username..."
            nameForm.autocorrectionType = .no
        }
        
        let save = UIAlertAction(title: "Save", style: .default) { [self] save in
            if alert.textFields![0].text?.count ?? 0 > 2 && alert.textFields![0].text?.count ?? 21 < 21 && ((alert.textFields![0].text?.rangeOfCharacter(from: .alphanumerics)) != nil) {
                profileManager.name = alert.textFields![0].text!
                existingProfileRecord == nil ? print("•Profile CREATED") : print("😍Profile UPDATED")
                profileContext == .create ? createProfile() : updateProfile()
                isShowingSaveAlert = false
                cacheManager.addNameToCache(name: alert.textFields![0].text!)
                
            } else {
                alertItem = AlertContext.InvalidUsername
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
    
    
    func requestNotifcationPermission() {
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error {
                print("⚠️ \(error)")
            } else if success {
                print("✅💜 notification permission success!")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("notification big failure")
            }
        }
    }
    
    
    func subscribeToNotifications(profile: OKGNProfile) async {
        
        let predicate = NSPredicate(format: "name == %@", profile.name)
        let subscription = CKQuerySubscription(recordType: "OKGNProfile", predicate: predicate, subscriptionID: "friendRequestAddedToDatabase", options: .firesOnRecordUpdate)
        
        let notification = CKSubscription.NotificationInfo()
        notification.title = "Friend Request"
        notification.alertBody = "Open friend feed in app to see new friend request from \(profile.name)!"
        notification.soundName = "default"
            
        subscription.notificationInfo = notification

        
        CKContainer.default().publicCloudDatabase.save(subscription) { returnedSub, returnedError in
            if let error = returnedError {
                print(error)
            } else {
                print("💜✅ sucessfully subscribed to notfications")
            }
        }
    }
}
