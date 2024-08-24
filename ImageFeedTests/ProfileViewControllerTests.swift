//
//  ProfileViewControllerTests.swift
//  ImageFeedTests
//
//  Created by Aleksei Bondarenko on 24.8.2024.
//

import XCTest
@testable import ImageFeed

final class ProfileViewControllerTests: XCTestCase {
    
    func testViewDidLoadCallsPresenterViewDidLoad() {
        // Given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewController()
        viewController.presenter = presenter
        
        // When
        viewController.viewDidLoad()
        
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled, "Presenter's viewDidLoad should be called")
    }
    
    func testPresenterUpdatesAvatar() {
        // Given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewControllerSpy()
        presenter.view = viewController
        
        let url = URL(string: "https://example.com/avatar.jpg")!
        
        // When
        viewController.updateAvatar(url: url)
        
        // Then
        XCTAssertTrue(viewController.updateAvatarCalled, "ViewController should update avatar")
    }
    
    func testShowConfirmationAlertCalled() {
        // Given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewControllerSpy()
        viewController.presenter = presenter
        
        // When
        viewController.showConfirmationAlert()
        
        // Then
        XCTAssertTrue(viewController.showConfirmationAlertCalled, "ViewController should show confirmation alert")
    }
    
    func testPerformLogoutNotCallPresenterLogout() {
        // Given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewControllerSpy()
        viewController.presenter = presenter
        
        // When
        viewController.performLogout()
        
        // Then
        XCTAssertTrue(viewController.performLogoutCalled, "ViewController should call performLogout")
        XCTAssertFalse(presenter.logoutCalled, "Presenter's logout shouldn't be called")
    }
    
    func testUserInfoIsDisplayedCorrectly() {
        // Given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewController()
        presenter.view = viewController
        
        let profileResult = ProfileService.ProfileResult(id: "1", username: "testuser", first_name: "Test", last_name: "User", bio: "Test Bio")
        let profile = ProfileService.Profile(from: profileResult)
        
        // When
        viewController.updateUserInfo(usingDataFrom: profile)
        
        // Then
        XCTAssertEqual(viewController.userNameLabel.text, profile.name, "User's name should be displayed correctly")
        XCTAssertEqual(viewController.nickNameLabel.text, profile.loginName, "User's login name should be displayed correctly")
        XCTAssertEqual(viewController.descriptionLabel.text, profile.bio, "User's bio should be displayed correctly")
    }
}


