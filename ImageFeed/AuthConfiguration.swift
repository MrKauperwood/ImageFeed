//
//  Constants.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 2.7.2024.
//

import Foundation

enum Constants {
    static let accessKey = "6uEqr9Ih6E7ChOa1Ao7cYgCUTOBoUEyOGjSTNfsWqLY"
    static let secretKey = "ITVI9uVdEerDZyAAwgKSQ6Ue5PBRdwLqded_69fHRRg"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    
    static let getTokenURL = URL(string: "https://unsplash.com/oauth/token")!
    static let getPhotosURL = defaultBaseURL.appendingPathComponent("photos")
    static func changeLikePhotoURL(for photoID: String) -> URL {
        return defaultBaseURL.appendingPathComponent("photos/\(photoID)/like")
    }
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}


struct AuthConfiguration {
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 authURLString: Constants.unsplashAuthorizeURLString,
                                 defaultBaseURL: Constants.defaultBaseURL)
    }
    
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String

    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
}
