//
//  ImageListGetPhotosResponse.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 30.7.2024.
//

import Foundation

struct PhotoResult: Decodable {
    let id: String
    let slug: String?
    let createdAt: String
    let updatedAt: String
    let width: Int
    let height: Int
    let color: String?
    let blurHash: String?
    let description: String?
    let altDescription: String?
    let urls: UrlsResult
    let likes: Int
    let likedByUser: Bool
    let currentUserCollections: [String]?
    let assetType: String?
    let user: UserResult?
}

struct UrlsResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
    let smallS3: String
}

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

struct ProfileImageResult: Decodable {
    let small: String
    let medium: String
    let large: String
}

struct SocialResult: Decodable {
    let instagramUsername: String?
    let portfolioUrl: String?
    let twitterUsername: String?
    let paypalEmail: String?
}

// Photo for UI
struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

extension Photo {
    init(from photoResult: PhotoResult) {
        self.id = photoResult.id
        self.size = CGSize(width: photoResult.width, height: photoResult.height)
        
        let dateFormatter = ISO8601DateFormatter()
        self.createdAt = dateFormatter.date(from: photoResult.createdAt)
        
        self.welcomeDescription = photoResult.description
        self.thumbImageURL = photoResult.urls.thumb
        self.largeImageURL = photoResult.urls.full
        self.isLiked = photoResult.likedByUser
    }
}


