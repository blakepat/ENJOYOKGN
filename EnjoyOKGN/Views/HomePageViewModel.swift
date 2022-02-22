//
//  HomePageViewModel.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-14.
//

import CloudKit

enum ProfileContext { case create, update }

final class HomePageViewModel: ObservableObject {
    
    @Published var isShowingPhotoPicker = false
    @Published var profile: OKGNProfile?
    private var existingProfileRecord: CKRecord? {
        didSet { profileContext = .update }
    }
    var profileContext: ProfileContext = .create
    @Published var avatar = PlaceholderImage.avatar
    @Published var name = "enter name..."
    
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
            wineryCount = userReviews?.filter({returnCategoryFromString($0.location.category) == .Winery}).count ?? 0
            breweryCount = userReviews?.filter({returnCategoryFromString($0.location.category) == .Brewery}).count ?? 0
            cafeCount = userReviews?.filter({returnCategoryFromString($0.location.category) == .Cafe}).count ?? 0
            pizzeriaCount = userReviews?.filter({returnCategoryFromString($0.location.category) == .Pizzeria}).count ?? 0
            activityCount = userReviews?.filter({returnCategoryFromString($0.location.category) == .Activity}).count ?? 0
            print("userREviews set in model")
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
            print("1")
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
                    print("success getting profile")
                    existingProfileRecord = record
                    let importedProfile = OKGNProfile(record: record)
                    profile = importedProfile
                    name = importedProfile.name
                    avatar = importedProfile.createProfileImage()
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
        
        profileRecord[OKGNProfile.kName] = name
        profileRecord[OKGNProfile.kAvatar] = avatar.convertToCKAsset()
        
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
        profileRecord[OKGNProfile.kName] = name
        profileRecord[OKGNProfile.kAvatar] = avatar.convertToCKAsset()
        
        return profileRecord
        
    }
}
