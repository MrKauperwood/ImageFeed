//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 9.7.2024.
//

import Foundation
import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Private Properties
    private let storage = OAuth2TokenStorage()
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthScreen"
    private let tabBarControllerIdentifier = "TabBarViewController"
    private let authViewForAuthControllerIdentifier = "NavigationViewForAuthController"
    
    // MARK: - Overrides Methods
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if storage.token != nil {
            switchRootViewController(to: tabBarControllerIdentifier)
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    // MARK: - Private Methods
    private func switchRootViewController(to identifier: String) {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let viewController: UIViewController
        if identifier == authViewForAuthControllerIdentifier {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let navigationController = storyboard.instantiateViewController(withIdentifier: authViewForAuthControllerIdentifier) as! UINavigationController
            if let authViewController = navigationController.viewControllers.first as? AuthViewController {
                authViewController.delegate = self
            }
            viewController = navigationController
        } else {
            viewController = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: identifier)
        }
        
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
    
}

extension SplashViewController : AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) {
            self.switchRootViewController(to: self.tabBarControllerIdentifier)
        }
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
