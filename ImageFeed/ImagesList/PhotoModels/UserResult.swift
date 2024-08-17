//
//  UserResult.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 17.8.2024.
//

import Foundation

struct UserResult: Decodable {
    let id: String
    let updatedAt: String
    let username: String?
    let name: String?
    let firstName: String?
    let lastName: String?
    let twitterUsername: String?
    let portfolioUrl: String?
    let bio: String?
    let location: String?
    let profileImage: ProfileImageResult?
    let instagramUsername: String?
    let totalCollections: Int?
    let totalLikes: Int?
    let totalPhotos: Int?
    let totalPromotedPhotos: Int?
    let totalIllustrations: Int?
    let totalPromotedIllustrations: Int?
    let acceptedTos: Bool
    let forHire: Bool
    let social: SocialResult?
}
