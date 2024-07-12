//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 7.7.2024.
//

import Foundation

final class OAuth2TokenStorage {
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let tokenKey = "BearerToken"
    
    
    // MARK: - Public Methods
    var token: String? {
        get {
            return userDefaults.string(forKey: tokenKey)
        }
        set {
            userDefaults.set(newValue, forKey: tokenKey)
        }
    }
}
