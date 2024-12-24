//
//  AlertItem.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-02-09.
//

import SwiftUI


struct AlertItem: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text
    let dismissButton: Alert.Button
}

struct TwoButtonAlertItem: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text
    let acceptButton: Alert.Button
    let dismissButton: Alert.Button
}


struct AlertContext {
    
    static let cannotRetrieveLocations = AlertItem(title: Text("Cannot Retrieve Locations"), message: Text("Unable to retrieve locations at this time. Please check your internet connection and that your are signed in to your iCloud and try again later, Thank you."), dismissButton: .default(Text("OK")))
    
    static let cannotRetrieveProfile = AlertItem(title: Text("Cannot Retrieve Profile"), message: Text("Unable to retrieve profile at this time. Please check your internet connection and that your are signed in to your iCloud and try again later, Thank you."), dismissButton: .default(Text("OK")))
    
    
    static let locationRestricted = AlertItem(title: Text("Location Restricted"), message: Text("Your location is restricted, this may be due to parental controls"), dismissButton: .default(Text("OK")))
    
    
    static let locationDenied = AlertItem(title: Text("Locations Denied"),
                                            message: Text("App does not have permission to acccess your location. To change that go to your phone's Settings > Enjoy OKGN > Location"),
                                            dismissButton: .default(Text("Ok")))
    
    static let locationDisabled = AlertItem(title: Text("Locations Denied"),
                                            message: Text("Your phone's location services are disabled. To change that go to your phone's Settings > Privacy > Location Services"),
                                            dismissButton: .default(Text("Ok")))

    static let profileCreateFailure = AlertItem(title: Text("Profile Creation Failed"),
                                            message: Text("We were unable to create your profile at this time. Please check your network connection and make sure you are signed into your iCloud account in phone settings."),
                                            dismissButton: .default(Text("Ok")))
    
    static let profileUpdateFailure = AlertItem(title: Text("Profile Update Failed"),
                                            message: Text("We were unable to update your profile at this time. Please check your network connection and try again later."),
                                            dismissButton: .default(Text("Ok")))
    
    static let profileUpdateSuccess = AlertItem(title: Text("Profile Update Success"),
                                            message: Text("Your EnjoyOKGN Profile has been successfully updated!."),
                                            dismissButton: .default(Text("Sweet!")))
    
    static let unableToCallWithDevice = AlertItem(title: Text("Unable to complete Call"), message: Text("Your device is not able to make phone calls at this time. Please try again on another device"), dismissButton: .default(Text("OK")))
    
    static let invalidPhoneNumber = AlertItem(title: Text("Unable to complete Call"), message: Text("The phone number for location is invalid, please check for an updated phone number elsewhere. Sorry for the inconvenience."), dismissButton: .default(Text("OK")))
    
    
    static let successfullyCreatedReview = AlertItem(title: Text("Review Created!"), message: Text("Your review has been successfully created!"), dismissButton: .default(Text("Sweet!")))
    
    static let reviewImproperlyFilledOut = AlertItem(title: Text("Please fill in all sections of review"), message: Text("Please ensure all areas of the review have been completed and your rating is between 0.1 - 10.0, Thank you!"), dismissButton: .default(Text("OK")))
    
    static let notSignedIntoProfile = AlertItem(title: Text("Review Creation Failed"),
                                            message: Text("We were unable to create your review at this time. Please check your network connection, that you have created an account on the main page, and you are signed into your iCloud account in phone settings."),
                                            dismissButton: .default(Text("Ok")))
    
    static let locationFavouritedSuccess = AlertItem(title: Text("Location Favourited"),
                                            message: Text("This location has been added to your favourite locations!"),
                                            dismissButton: .default(Text("Ok")))
    
    static let locationFavouritedFailed = AlertItem(title: Text("Error"),
                                            message: Text("There was an error trying to add this location to your favourites. Please make sure you are signed in and try again later"),
                                            dismissButton: .default(Text("Ok")))
    
    static let locationUnfavouritedSuccess = AlertItem(title: Text("Location Removed"),
                                            message: Text("This location has been removed from your favourite locations"),
                                            dismissButton: .default(Text("Ok")))
    
    
    static let locationUnfavouritedFailed = AlertItem(title: Text("Error"),
                                            message: Text("There was an error trying to remove this location from your favourites. Please make sure you are signed in and try again later"),
                                            dismissButton: .default(Text("Ok")))
    
    
    static let InvalidUsername = AlertItem(title: Text("Invalid Username"),
                                            message: Text("Please use a username that is between 3 and 20 characters and does not use special characters"),
                                            dismissButton: .default(Text("Ok")))
    
    
    static let reviewCreationFailed = AlertItem(title: Text("Creating Review Unsuccessful"),
                                            message: Text("Please check that have a internet connection and you are signed into your iCloud account in the settings of your iPhone and try again later. Thank you!"),
                                            dismissButton: .default(Text("Ok")))
    
    static let usernameAlreadyExists = AlertItem(title: Text("User already exists"),
                                            message: Text("Please change your username to a different one"),
                                            dismissButton: .default(Text("Ok")))
    
}

extension AlertContext {
    static let profileNotFound = AlertItem(
        title: Text("Profile Error"),
        message: Text("Unable to find your profile. Please try again later."),
        dismissButton: .default(Text("OK"))
    )
    
    static let unableToLoadUsers = AlertItem(
        title: Text("Loading Error"),
        message: Text("Unable to load users. Please check your connection and try again."),
        dismissButton: .default(Text("OK"))
    )
    
    static let unableToLoadMoreUsers = AlertItem(
        title: Text("Loading Error"),
        message: Text("Unable to load more users. Please try again."),
        dismissButton: .default(Text("OK"))
    )
    
    
    static let unableToSendFriendRequest = AlertItem(
        title: Text("Friend Request Error"),
        message: Text("Unable to send friend request. Please try again later."),
        dismissButton: .default(Text("OK"))
    )
    
    static let unableToCancelRequest = AlertItem(
        title: Text("Cancel Request Error"),
        message: Text("Unable to cancel friend request. Please try again later."),
        dismissButton: .default(Text("OK"))
    )
}
