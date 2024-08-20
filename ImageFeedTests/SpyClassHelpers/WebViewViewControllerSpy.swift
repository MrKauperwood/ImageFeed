//
//  WebViewViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Aleksei Bondarenko on 20.8.2024.
//

import Foundation
import XCTest
@testable import ImageFeed


final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: ImageFeed.WebViewPresenterProtocol?

    var loadRequestCalled: Bool = false

    func load(request: URLRequest) {
        loadRequestCalled = true
    }

    func setProgressValue(_ newValue: Float) {

    }

    func setProgressHidden(_ isHidden: Bool) {

    }
}
