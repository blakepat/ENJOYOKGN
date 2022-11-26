//
//  CreateReviewViewModel.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-10-10.
//

import SwiftUI
import CloudKit


final class CreateReviewViewModel: ObservableObject {
    
    @Published var locationName: String = ""
    @Published var caption: String = ""
    @Published var locationNamesIdsCategory = [(CKRecord.ID, String, String)]() 
    @Published var firstNumber = 0
    @Published var secondNumber = 0
    @Published var selectedLocation: OKGNLocation?
    @Published var selectedLocationId: CKRecord.ID?
    @Published var selectedLocationCategory: String?
    @Published var selectedImage: UIImage = PlaceholderImage.square
    @Published var alertItem: AlertItem?
    @Published var isShowingPhotoPicker = false
    @Published var showLoadingView = false
    @Published var showAlertView = false
    @Published var showingExpandedList = false
    @Published var searchText = ""
    
    var searchResults: [(CKRecord.ID, String, String)] {
       if searchText.isEmpty {
           return locationNamesIdsCategory
       } else {
           return locationNamesIdsCategory.filter({ $0.1.contains(searchText)
           })
       }
    }
    
}
