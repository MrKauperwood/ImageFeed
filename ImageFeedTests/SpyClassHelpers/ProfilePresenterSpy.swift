//
//  ProfilePresenterSpy.swift
//  ImageFeedTests
//
//  Created by Aleksei Bondarenko on 24.8.2024.
//

import Foundation
import XCTest
@testable import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var logoutCalled: Bool = false
    weak var view: ProfileControllerProtocol?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func logout() {
        logoutCalled = true
    }
}
