//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 4.7.2024.
//

import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController : UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet private var logInButton: UIButton!
    
    // MARK: - Public Properties
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Private Properties
    private let oauth2Service = OAuth2Service.shared
    private let tokenStorage = OAuth2TokenActions()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWebView",
           let webViewViewController = segue.destination as? WebViewViewController {
            webViewViewController.delegate = self
        }
    }
    
    
    // MARK: - Private Methods
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.navigationController?.popViewController(animated: true)
        
        print("Delegate method called with code: \(code)")
        UIBlockingProgressHUD.show()
        
        oauth2Service.fetchOAuthToken(code: code) {[weak self] result in
            guard let self = self else { return }
                switch result {
                case .success(let token):
                    print("Token received: \(token)")
                    self.tokenStorage.saveTokenInStorage(token: token)
                    UIBlockingProgressHUD.dismiss()
                    self.delegate?.didAuthenticate(self)
                    
                case .failure(let error):
                    print("Failed to fetch token: \(error)")
                    UIBlockingProgressHUD.dismiss()
                    print("Dismissing loader")
                    DispatchQueue.main.async {
                        self.showAlert(title: "Что-то пошло не так(", message: "Не удалось войти в систему")
                    }
                    print("Showing alert")
            }
        }
        
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true, completion: nil)
    }
}

extension UIViewController {
    func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
    }
}
