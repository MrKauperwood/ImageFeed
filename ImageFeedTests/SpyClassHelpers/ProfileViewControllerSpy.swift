//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Aleksei Bondarenko on 24.8.2024.
//

import Foundation
import XCTest
@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    
    var updateUserInfoCalled: Bool = false
    var updateAvatarCalled: Bool = false
    var performLogoutCalled: Bool = false
    var showConfirmationAlertCalled: Bool = false

    func updateUserInfo(usingDataFrom profile: ProfileService.Profile) {
        updateUserInfoCalled = true
    }

    func updateAvatar(url: URL) {
        updateAvatarCalled = true
    }

    func performLogout() {
        performLogoutCalled = true
    }

    func showConfirmationAlert() {
        showConfirmationAlertCalled = true
    }
}
