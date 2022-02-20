//
//  ReviewManager.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-16.
//

import SwiftUI


final class ReviewManager: ObservableObject {
    
    @Published var reviews: [OKGNReview] = [] {
        willSet {
            objectWillChange.send()
            print("reviews set!")
        }
    }
    
}
