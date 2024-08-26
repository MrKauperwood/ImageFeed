//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 14.8.2024.
//

import Foundation
import WebKit
import SwiftKeychainWrapper

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    internal init() { }
    
    public func logout() {
        cleanCookies()
        cleanProfileData()
        cleanProfileImage()
        cleanImagesList()
        removeTokenFromKeychain()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func cleanProfileData() {
        ProfileService.shared.clearProfile()
        Logger.logMessage("Profile data cleared", for: self, level: .info)
    }
    
    private func cleanProfileImage() {
        ProfileImageService.shared.clearUserImage()
        Logger.logMessage("Profile image cleared", for: self, level: .info)
    }
    
    private func cleanImagesList() {
        let imagesListService = ImagesListService()
        imagesListService.clearImagesList()
        Logger.logMessage("Images list cleared", for: self, level: .info)
    }
    
    private func removeTokenFromKeychain() {
        let tokenActions = OAuth2TokenActions()
        let tokenKey = tokenActions.getTokenKey()
        
        let keychainWrapper = KeychainWrapper.standard
        keychainWrapper.removeObject(forKey: tokenKey)
        Logger.logMessage("Token removed from Keychain", for: self, level: .info)
    }
}

