//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 11.7.2024.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
}
