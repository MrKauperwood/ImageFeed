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
    
    static let accessScope = "public read_user write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    
    static let getTokenURL = URL(string: "https://unsplash.com/oauth/token")!
}
