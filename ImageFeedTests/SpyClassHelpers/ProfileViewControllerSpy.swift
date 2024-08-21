//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Aleksei Bondarenko on 21.8.2024.
//

import Foundation
import XCTest
@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewProtocol {
    private(set) var performLogoutCalled = false
    private(set) var showConfirmationAlertCalled = false
    
    func performLogout() {
        performLogoutCalled = true
        
    }
    
    func showConfirmationAlert() {
        showConfirmationAlertCalled = true
        
    }
    
    @objc func logOutButtonTapped() {
        showConfirmationAlert()
    }
}
