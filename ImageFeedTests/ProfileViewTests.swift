//
//  ProfileViewTests.swift
//  ImageFeedTests
//
//  Created by Aleksei Bondarenko on 21.8.2024.
//

import XCTest
@testable import ImageFeed

final class ProfileViewTests: XCTestCase {
    
    func testInitUIComponents() {
        // Given
        let sut = ProfileViewController()
        
        // When
        sut.loadViewIfNeeded()
        
        // Then
        XCTAssertNotNil(sut.imageView)
        XCTAssertNotNil(sut.userNameLabel)
        XCTAssertNotNil(sut.nickNameLabel)
        XCTAssertNotNil(sut.descriptionLabel)
        XCTAssertNotNil(sut.button)
    }
    
    func testUpdateAvatarSuccess() {
        // Given
        let sut = ProfileViewController()
        let url = URL(string: "https://via.placeholder.com/70")!
        let expectation = self.expectation(description: "Avatar loaded")
        
        // When
        sut.loadViewIfNeeded()
        sut.imageView.kf.setImage(with: url) { _ in
            expectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 2) { _ in
            XCTAssertNotNil(sut.imageView.image)
        }
    }
    
    func testShowAlert() {
        // Given
        let sut = ProfileViewController()
        let spy = ProfileViewControllerSpy()
        
        // When
        sut.loadViewIfNeeded()
        spy.logOutButtonTapped()
        
        //Then
        XCTAssertTrue(spy.showConfirmationAlertCalled)
    }
}
