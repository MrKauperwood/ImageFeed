//
//  ImagesListViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Aleksei Bondarenko on 24.8.2024.
//

import UIKit
@testable import ImageFeed

import UIKit
@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListControllerProtocol, ImagesListCellDelegate {
    var presenter: ImagesListPresenterProtocol?
    
    var reloadTableViewCalled = false
    var updateLikeStateCalled = false
    var showLoadingIndicatorCalled = false
    var hideLoadingIndicatorCalled = false
    var updateTableViewAnimatedCalled = false
    var performSegueCalled = false
    var imageListCellDidTapLikeCalled = false
    
    var tableView = UITableView()
    
    func updateTableView() {
        reloadTableViewCalled = true
    }
    
    func updateLikeState(at index: Int) {
        updateLikeStateCalled = true
    }
    
    func showLoadingIndicator() {
        showLoadingIndicatorCalled = true
    }
    
    func hideLoadingIndicator() {
        hideLoadingIndicatorCalled = true
    }
    
    func updateTableViewAnimated() {
        updateTableViewAnimatedCalled = true
    }
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        imageListCellDidTapLikeCalled = true
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.toggleLike(at: indexPath.row) { _ in }
    }
}
