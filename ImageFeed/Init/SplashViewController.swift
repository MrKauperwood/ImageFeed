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
    private let storage = OAuth2TokenActions()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthScreen"
    private let tabBarControllerIdentifier = "TabBarViewController"
    private let authViewForAuthControllerIdentifier = "NavigationViewForAuthController"
    
    // MARK: - UI Elements
    private let splashImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Logo_of_Unsplash"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Overrides Methods
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.getTokenFromStorage() {
            fetchProfile(token)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            self.present(authViewController, animated: true, completion: nil)
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
    
    private func setupUI() {
        view.addSubview(splashImageView)
        
        NSLayoutConstraint.activate([
            splashImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
}

extension SplashViewController : AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = storage.getTokenFromStorage() else {
            return
        }
        
        fetchProfile(token)
    }
    
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                print("Profile fetched successfully:")
                print("Username: \(profile.username)")
                print("Name: \(profile.name)")
                print("Login Name: \(profile.loginName)")
                print("Bio: \(profile.bio ?? "No bio available")")
                
                fetchProfileImageURL(username: profile.username)
                
                self.switchRootViewController(to: self.tabBarControllerIdentifier)
                
            case .failure(let error):
                print("Failed to fetch profile with error: \(error.localizedDescription)")
                break
            }
        }
        
    }
    
    private func fetchProfileImageURL(username: String) {
        profileImageService.fetchProfileImageURL(username: username) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let profileImage):
                print("Profile image fetched successfully:")
                print("Image url: \(profileImage)")
                
                self.switchRootViewController(to: self.tabBarControllerIdentifier)
                
            case .failure(let error):
                print("Failed to fetch profile with error: \(error.localizedDescription)")
                break
            }
        }
        
    }
}
