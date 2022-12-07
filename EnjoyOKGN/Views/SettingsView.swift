//
//  SettingsView.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-06-25.
//

import SwiftUI
import CloudKit

struct SettingsView: View {
    
    @Environment(\.openURL) var openURL
    private var email = EmailAddLocation(toAddress: "blakepat@me.com",
                                         subject: "EnjoyOKGN Location Request",
                                         messageHeader: "Please include name, address, and recommended category. Thank you!")
    
//    let coffeeURL = URL(string: "https://www.buymeacoffee.com/blakepat")!
    let portfolioURL = URL(string: "https://blakepat.wixsite.com/portfolio")!
    @Environment(\.presentationMode) var presentationMode
    
    init() {
        UITableView.appearance().backgroundColor = UIColor(named: "OKGNDarkGray")
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor : UIColor.white]
        }
    
    
    var body: some View {

        NavigationView {
            ZStack {
                Color.OKGNDarkGray.ignoresSafeArea()
                
                List {
                    aboutSection
                    emailSection
//                    notificationSection
                }
                .navigationTitle("Settings")
                .listStyle(.grouped)
                .toolbar {
                    XDismissButton(color: .OKGNDarkYellow)
                        .onTapGesture {
                            presentationMode.wrappedValue.dismiss()
                        }
                }
            }
        }
    }
}



extension SettingsView {
    
    private var aboutSection: some View {
        Section {
            VStack(alignment: .leading) {
                Image("GoldTrophy")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                Text("This app was created by me, Blake Pat. I am an aspiring iOS Developer! Check out my portfolio below so you can see my other iOS apps!")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(Color.gray)
            }
            .padding(.vertical)
            
//            Link("Support coffee addiction ☕️", destination: coffeeURL)
            Link("iOS Portfolio 💼", destination: portfolioURL)
            
        } header: {
            Text("About")
                .foregroundColor(.white)
        }
        .listRowBackground(Color(UIColor(named: "OKGNSecondaryDarkGray")!))
    }
    
    
    private var emailSection: some View {
        Section {
            VStack(alignment: .leading) {
                Image("SilverTrophy")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                Text("If there is a location that is not yet listed, please contact me with the link below and I will add it asap if it is applicable! Thank you for your contribution to our growing catalog!")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(Color.gray)
            }
            .padding(.vertical)
            
            Button {
                email.send(openURL: openURL)
            } label: {
                Text("New Location 📧")
            }
            
            
        } header: {
            Text("New Location")
                .foregroundColor(.white)
        }
        .listRowBackground(Color(UIColor(named: "OKGNSecondaryDarkGray")!))
    }
    
    
    private var notificationSection: some View {
        Section {
            VStack(alignment: .leading) {
                Image("BronzeTrophy")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                Text("If you no longer wish to receive notifications from us (this includes friend requests) or if you wish to start receiving notifications:")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(Color.gray)
            }
            .padding(.vertical)
            
            Button {
                unsubscribeToNotfications()
            } label: {
                Text("Unsubscibe 🔕")
            }
            
            Button {
                requestNotifcationPermission()
                if let user = CloudKitManager.shared.userRecord {
                    subscribeToNotifications(user: user)
                }
            } label: {
                Text("Subscibe to notifications 🔔")
            }
        } header: {
            Text("Notifications")
                .foregroundColor(.white)
        }
        .listRowBackground(Color(UIColor(named: "OKGNSecondaryDarkGray")!))
    }
    
    func unsubscribeToNotfications() {
        
        CKContainer.default().publicCloudDatabase.delete(withSubscriptionID: "friendRequestAddedToDatabase") { returnedID, returnedError in
            if let error = returnedError {
                print(error)
            } else {
                print("✅ successfully unsubscibed!")
            }
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
    
    
    func subscribeToNotifications(user: CKRecord) {
        
        let predicate = NSPredicate(value: true)
        
        let subscription = CKQuerySubscription(recordType: "OKGNProfile", predicate: predicate, subscriptionID: "friendRequestAddedToDatabase", options: .firesOnRecordUpdate)
        
        let notification = CKSubscription.NotificationInfo()
        notification.title = "Friend Request"
        notification.alertBody = "Open friend feed in app to see new friend request!"
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
