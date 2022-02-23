//
//  UIImage+Ext.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-11.
//

import CloudKit
import UIKit

extension UIImage {
    
    func convertToCKAsset(path: String) -> CKAsset? {
        
        
        // Get apps base document directory url
        guard let urlPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Doc directory came back nil")
            return nil
        }
        
        // Append unique id for profile image
        let fileUrl = urlPath.appendingPathComponent(path)
        
        // Write the image data to the locations to the address
        
        guard let imageData = jpegData(compressionQuality: 0.25) else { return nil }
        
        // create
        do {
            try imageData.write(to: fileUrl)
            return CKAsset(fileURL: fileUrl)
        } catch {
            return nil
        }
    }
}
