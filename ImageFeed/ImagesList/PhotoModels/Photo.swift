//
//  Photo.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 17.8.2024.
//

import Foundation
import CoreGraphics

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let smallImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

extension Photo {
    private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    init(from photoResult: PhotoResult) {
        self.id = photoResult.id
        self.size = CGSize(width: photoResult.width, height: photoResult.height)

        self.createdAt = Photo.dateFormatter.date(from: photoResult.createdAt)

        self.welcomeDescription = photoResult.description
        self.thumbImageURL = photoResult.urls.thumb
        self.smallImageURL = photoResult.urls.small
        self.largeImageURL = photoResult.urls.full
        self.isLiked = photoResult.likedByUser
    }
}
