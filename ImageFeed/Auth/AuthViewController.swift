//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 4.7.2024.
//

import Foundation
import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController : UIViewController, WebViewViewControllerDelegate {
    weak var delegate: AuthViewControllerDelegate?
    
    private let oauth2Service = OAuth2Service.shared
    private let tokenStorage = OAuth2TokenStorage()
    
    @IBOutlet var logInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        
        print("Delegate method called with code: \(code)")
        
        oauth2Service.fetchOAuthToken(code: code) {
            result in
            switch result {
            case .success(let token):
                print("Token received: \(token)")
                self.tokenStorage.token = token
                self.delegate?.didAuthenticate(self)
                
            case .failure(let error):
                print("Failed to fetch token: \(error)")
            }
        }
        
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWebView",
           let webViewViewController = segue.destination as? WebViewViewController {
            webViewViewController.delegate = self
        }
    }
    
}

