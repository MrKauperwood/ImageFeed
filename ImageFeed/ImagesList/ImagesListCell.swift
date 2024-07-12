//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 10.5.2024.
//

import Foundation
import UIKit

final class ImagesListCell: UITableViewCell {
    // MARK: - IB Outlets
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    // MARK: - Public Properties
    static let reuseIdentifier = "ImagesListCell"
}
