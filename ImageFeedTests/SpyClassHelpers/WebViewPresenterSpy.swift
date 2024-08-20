//
//  WebViewPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Aleksei Bondarenko on 20.8.2024.
//

import Foundation
import XCTest
@testable import ImageFeed


final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
    }
}
