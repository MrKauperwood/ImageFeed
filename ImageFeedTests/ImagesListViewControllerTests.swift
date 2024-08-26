//
//  ImagesListViewControllerTests.swift
//  ImageFeedTests
//
//  Created by Aleksei Bondarenko on 24.8.2024.
//

import XCTest
@testable import ImageFeed
import CoreGraphics

final class ImagesListViewControllerTests: XCTestCase {
    
    func testUpdateTableViewReloadsTableView() {
        // Given
        let viewController = ImagesListViewControllerSpy()
        
        // When
        viewController.updateTableView()
        
        // Then
        XCTAssertTrue(viewController.reloadTableViewCalled, "updateTableView should reload the table view")
    }
    
    func testUpdateLikeState() {
        // Given
        let presenter = ImagesListPresenterSpy()
        let viewController = ImagesListViewControllerSpy()
        viewController.presenter = presenter
        
        let index = 0
        let photo = Photo(
            id: "1",
            size: CGSize(width: 100, height: 100),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "",
            smallImageURL: "",
            largeImageURL: "",
            isLiked: false
        )
        presenter.photos = [photo]
        
        // When
        viewController.updateLikeState(at: index)
        
        // Then
        XCTAssertTrue(viewController.updateLikeStateCalled, "updateLikeState should be called")
    }
    
    func testShowLoadingIndicator() {
        // Given
        let viewController = ImagesListViewControllerSpy()
        
        // When
        viewController.showLoadingIndicator()
        
        // Then
        XCTAssertTrue(viewController.showLoadingIndicatorCalled, "Loading indicator should be shown")
    }
    
    func testHideLoadingIndicator() {
        // Given
        let viewController = ImagesListViewControllerSpy()
        
        // When
        viewController.hideLoadingIndicator()
        
        // Then
        XCTAssertTrue(viewController.hideLoadingIndicatorCalled, "Loading indicator should be hidden")
    }
    
    func testUpdateTableViewAnimated() {
        // Given
        let presenter = ImagesListPresenterSpy()
        let viewController = ImagesListViewControllerSpy()
        viewController.presenter = presenter
        
        let photo = Photo(
            id: "1",
            size: CGSize(width: 100, height: 100),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "",
            smallImageURL: "",
            largeImageURL: "",
            isLiked: false
        )
        presenter.photos = [photo]
        
        // When
        viewController.updateTableViewAnimated()
        
        // Then
        XCTAssertTrue(viewController.updateTableViewAnimatedCalled, "TableView should be updated with animation")
    }
    
    func testPrepareForSegue() {
        // Given
        let presenter = ImagesListPresenterSpy()
        let viewController = ImagesListViewController()
        viewController.presenter = presenter
        
        let photo = Photo(
            id: "1",
            size: CGSize(width: 100, height: 100),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "",
            smallImageURL: "",
            largeImageURL: "https://example.com",
            isLiked: false
        )
        presenter.photos = [photo]
        
        let segue = UIStoryboardSegue(identifier: "ShowSingleImage", source: viewController, destination: SingleImageViewController())
        
        // When
        viewController.prepare(for: segue, sender: IndexPath(row: 0, section: 0))
        
        // Then
        let destinationVC = segue.destination as? SingleImageViewController
        XCTAssertEqual(destinationVC?.imageUrl, photo.largeImageURL, "The destination view controller should receive the correct photo URL")
    }
}
