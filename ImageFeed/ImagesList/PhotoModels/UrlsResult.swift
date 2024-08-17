//
//  UrlsResult.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 17.8.2024.
//

import Foundation

struct UrlsResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
    let smallS3: String
}
