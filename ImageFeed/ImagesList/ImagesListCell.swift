//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 10.5.2024.
//

import Foundation
import UIKit

// MARK: - ImagesListCellDelegate

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

// MARK: - ImagesListCell

final class ImagesListCell: UITableViewCell {

    // MARK: - IB Outlets
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    // MARK: - Public Properties
    
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?

    // MARK: - Overrides Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Отменяем загрузку изображения
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
    }

    // MARK: - IB Actions
    
    @IBAction private func likeButtonClicked(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }

    // MARK: - Public Methods
    
    func setIsLiked(_ isLiked: Bool) {
        DispatchQueue.main.async {
            let likeImage = isLiked ? UIImage(named: "ActiveLike") : UIImage(named: "NotActiveLike")
            self.likeButton.setImage(likeImage, for: .normal)
        }
    }
}
