//
//  ProfileManager.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-02-22.
//

import SwiftUI
import CloudKit

final class ProfileManager: ObservableObject {
    
    @Published var avatar: UIImage = PlaceholderImage.avatar
    @Published var name: String = "Enter name..."

}


class CacheManager {
    
    static let instance = CacheManager()
    private init() {}
    
    var avatarCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 1
        return cache
    }()
    var nameCache: NSCache<NSString, NSString> = {
        let cache = NSCache<NSString, NSString>()
        cache.countLimit = 1
        return cache
    }()
    
    func addAvatarToCache(avatar: UIImage) {
        removeAvatarFromCache()
        avatarCache.setObject(avatar, forKey: "avatar" as NSString)
    }
    
    func addNameToCache(name: String) {
        removeNameFromCache()
        nameCache.setObject(name as NSString, forKey: "name" as NSString)
    }
    
    func removeAvatarFromCache() {
        avatarCache.removeObject(forKey: "avatar" as NSString)
        
    }
    
    func removeNameFromCache() {
        nameCache.removeObject(forKey: "name" as NSString)
    }
    
    func getAvatarFromCache() -> UIImage? {
        return avatarCache.object(forKey: "avatar" as NSString)
    }
    
    func getNameFromCache() -> String? {
        return nameCache.object(forKey: "name" as NSString) as String?
    }
    
}
