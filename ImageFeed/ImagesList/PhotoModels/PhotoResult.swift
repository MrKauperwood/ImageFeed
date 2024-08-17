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
