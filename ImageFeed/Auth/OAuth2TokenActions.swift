//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 7.7.2024.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenActions {
    // MARK: - Private Properties
    private let tokenKey = "AuthToken"
    
    func getTokenFromStorage() -> String? {
        return KeychainWrapper.standard.string(forKey: tokenKey)
    }
    
    func saveTokenInStorage(token: String) {
        let isSuccess = KeychainWrapper.standard.set(
            token,
            forKey: tokenKey,
            withAccessibility: .whenPasscodeSetThisDeviceOnly)
        guard isSuccess else {
            print("Failed to save the token to the keychain")
            return
        }
    }
    
    func removeTokenFromStorage() {
        let isSuccess = KeychainWrapper.standard.removeObject(forKey: tokenKey)
        guard isSuccess else {
            print("Failed to remove the token from the keychain")
            return
        }
    }
}
