//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 9.7.2024.
//

import Foundation
import UIKit

final class SplashViewController: UIViewController {
    
    private let storage = OAuth2TokenStorage()
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthScreen"
    private var isTokenExist = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defineNextScreen()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            print("Token exists: \(token)")
            isTokenExist = true
        }
    }
    
    private func defineNextScreen() {
        if isTokenExist {
            print("Okay, token exists!")
//            goToGalleryFlow()
        } else {
            print("OPPPPS, no token")
            goToAuthFlow()
        }
    }
    
    private func goToGalleryFlow() {
        
    }
    
    private func goToAuthFlow() {
        performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
    }
}
