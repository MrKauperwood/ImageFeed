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
    
    private init() { }
    
    func logout() {
        cleanCookies()
        cleanProfileData()
        cleanProfileImage()
        cleanImagesList()
        removeTokenFromKeychain()
    }
    
    private func cleanCookies() {
        // Очищаем все куки из хранилища
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            // Массив полученных записей удаляем из хранилища
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func cleanProfileData() {
        ProfileService.shared.clearProfile()
        print("Profile data cleared")
    }

    private func cleanProfileImage() {
        ProfileImageService.shared.clearUserImage()
        print("Profile image cleared")
    }
    
    private func cleanImagesList() {
        let imagesListService = ImagesListService()
        imagesListService.clearImagesList()
        print("Images list cleared")
    }
    
    private func removeTokenFromKeychain() {
        let tokenActions = OAuth2TokenActions()
        let tokenKey = tokenActions.getTokenKey()
        
        let keychainWrapper = KeychainWrapper.standard
        keychainWrapper.removeObject(forKey: tokenKey)
        print("Token removed from Keychain")
    }
}

