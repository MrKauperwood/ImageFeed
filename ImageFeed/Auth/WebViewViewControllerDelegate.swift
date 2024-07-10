//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 5.7.2024.
//

import Foundation

protocol WebViewViewControllerDelegate: AnyObject {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
    
}
