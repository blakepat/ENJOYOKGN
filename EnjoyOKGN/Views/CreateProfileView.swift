//
//  CreateProfileView.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-12-11.
//

import SwiftUI
import CloudKit

struct CreateProfileView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State var avatarSet = false
    @State var showPickerView = false
    
    let cacheManager = CacheManager.instance
    
    @State var alertItem: AlertItem?
    @State var showAlertView = false
    
    @State var username: String
    @State var avatarImage: UIImage
    @Binding var profileContext: ProfileContext
    @Binding var createdProfileRecord: CKRecord?
    @Binding var showCreateProfileView: Bool
    
    var body: some View {
        ZStack {
            
            LinearGradient(colors: [Color.OKGNDarkYellow, Color.OKGNDarkBlue],
                           startPoint: .top,
                           endPoint: .bottom).ignoresSafeArea()
                .overlay(
                    ZStack {
                        
                        backgroundWave2()
                            .fill(
                                LinearGradient(colors: [.OKGNLightGreen, .OKGNDarkYellow],
                                               startPoint: .topLeading,
                                               endPoint: .bottom)
                            )
                        
                        backgroundWave()
                            .fill(
                                LinearGradient(colors: [.OKGNLightGreen, .OKGNPeach],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing)
                            )
                            .ignoresSafeArea(edges: .bottom)
                    }
                )
            VStack(alignment: .center, spacing: 24) {
                
                HStack(spacing: 0) {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.OKGNDarkYellow)
                    
                    LinearGradient(colors: [.OKGNLightGreen, .OKGNDarkYellow],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                    .padding(.horizontal)
                    .frame(height: 100)
                    .mask {
                        Text(profileContext == .create ? "Create Profile" : "Update Profile")
                            .font(.largeTitle)
                            .bold()
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                    
                Image(uiImage: avatarImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Image(systemName: "square.and.pencil").offset(y: 36))
                    .onTapGesture {
                        showPickerView = true
                    }
                    
                
                VStack {
                    TextField("create username", text: $username)
                        .frame(width: 200)
                        .textFieldStyle(.roundedBorder)
                        .background(Color.OKGNDarkBlue)
                    
                    Text("Must be between 3 and 20 characters \n(no special characters)")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                }

                
                Button {
                    profileContext == .create ? createProfile() : updateProfile()
                } label: {
                    Text(profileContext == .create ? "Create Profile" : "Update Profile")
                        .padding(8)
                        .background(Color.OKGNDarkYellow)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .opacity(profileCorrectlyMade() ? 1 : 0.4)
                        
                }
                .allowsHitTesting(profileCorrectlyMade())
            }
            .padding()
            .background(
                LinearGradient(colors: [.OKGNDarkBlue, .clear],
                               startPoint: .top,
                               endPoint: .bottom)
            )
            .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(
                        LinearGradient(colors: [.white, .clear],
                                       startPoint: .top,
                                       endPoint: .bottom)
                        , lineWidth: 1)
                    .blendMode(.overlay)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .stroke(
                                LinearGradient(colors: [.white, .clear],
                                               startPoint: .top,
                                               endPoint: .bottom)
                                , lineWidth: 2)
                            .blur(radius: 5)
                    )
            )
            .background(
                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
                    .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
            )
            .padding()
        }
        .sheet(isPresented: $showPickerView) {
            PhotoPicker(image: $avatarImage)
        }
        .alert(alertItem?.title ?? Text(""), isPresented: $showAlertView, actions: {
            // actions
        }, message: {
            alertItem?.message ?? Text("")
        })
    }
    
    
    private func createProfile() {
        
        print("Created profile")
        //Create our CKRecord from the profile view
        let profileRecord = createProfileRecord()
        
        guard let userRecord = CloudKitManager.shared.userRecord else {
            // show an alert
            self.alertItem = AlertContext.profileCreateFailure
            showAlertView = true
            return
        }
        
        userRecord["userProfile"] = CKRecord.Reference(recordID: profileRecord.recordID, action: .none)
        
        Task {
            do {
                if let records = try await CloudKitManager.shared.batchSave(records: [userRecord, profileRecord]) {
                    for record in records where record.recordType == RecordType.profile {
                        CloudKitManager.shared.profileRecordID = record.recordID
                    }
                    DispatchQueue.main.async {
                        profileContext = .update
                        dismiss()
                        showCreateProfileView = false
                    }
                }
            } catch {
                self.alertItem = AlertContext.profileCreateFailure
                showAlertView = true
            }
        }
    }
    
    func updateProfile() {
        guard let profileRecord = createdProfileRecord else {
            self.alertItem = AlertContext.profileCreateFailure
            showAlertView = true
            return
        }
        
        profileRecord[OKGNProfile.kName] = username
        profileRecord[OKGNProfile.kAvatar] = avatarImage.convertToCKAsset(path: "profileAvatar")

        
        Task {
            do {
                let _ = try await CloudKitManager.shared.save(record: profileRecord)
//                alertItem = AlertContext.profileUpdateSuccess
                cacheManager.addNameToCache(name: username)
                cacheManager.addAvatarToCache(avatar: avatarImage)
//                showAlertView = true
                
                DispatchQueue.main.async {
                    dismiss()
                    showCreateProfileView = false
                }
            } catch {
                alertItem = AlertContext.profileUpdateFailure
                showAlertView = true
            }
        }
    }
    
    
    private func createProfileRecord() -> CKRecord {
        let profileRecord = CKRecord(recordType: RecordType.profile)
        profileRecord[OKGNProfile.kName] = username
        profileRecord[OKGNProfile.kAvatar] = avatarImage.convertToCKAsset(path: "avatarImage")
        
        return profileRecord
        
    }
    
    
    private func profileCorrectlyMade() -> Bool {
        return (username != "" && username.count >= 3 && username.count <= 20 && (username.rangeOfCharacter(from: .alphanumerics) != nil))
    }
}

//struct CreateProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateProfileView(createdProfileRecord: .constant(nil), showCreateProfileView: <#Binding<Bool>#>)
//    }
//}
