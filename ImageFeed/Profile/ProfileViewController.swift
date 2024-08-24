//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 20.5.2024.
//

import Foundation
import UIKit
import Kingfisher
import ProgressHUD

protocol ProfileControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateUserInfo(usingDataFrom profile : ProfileService.Profile)
    func updateAvatar(url: URL)
    func performLogout()
    func showConfirmationAlert()
}


final class ProfileViewController: UIViewController, ProfileControllerProtocol {
    
    // MARK: - Private Properties
    var presenter: ProfilePresenterProtocol?
    
    private let profileImage = UIImage()
    
    internal lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = profileImage
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        imageView.tintColor = .gray
        return imageView
    }()
    
    internal lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Алексей Бонд"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .ypWhite
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        return label
    }()
    
    internal lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "@lexabond"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .ypGrey
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    internal lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .ypWhite
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    internal lazy var button: UIButton = {
        let buttonImage = UIImage(systemName: "ipad.and.arrow.forward")
        let button = UIButton.systemButton(with: buttonImage!, target: self, action: #selector(logOutButtonTapped))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .ypRed
        button.accessibilityIdentifier = "logoutButton"
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        presenter?.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        presenter?.viewDidLoad()
    }
    
    private func setupUI() {
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
        
        view.addSubview(userNameLabel)
        NSLayoutConstraint.activate([
            userNameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            userNameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
        ])
        
        view.addSubview(nickNameLabel)
        NSLayoutConstraint.activate([
            nickNameLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8),
            nickNameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
        ])
        
        view.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),            descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 25),
            button.heightAnchor.constraint(equalToConstant: 25),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
    
    func updateUserInfo(usingDataFrom profile : ProfileService.Profile) {
        userNameLabel.text = profile.name
        nickNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    func updateAvatar(url: URL) {
        let processor = DownsamplingImageProcessor(size: imageView.bounds.size)
        |> RoundCornerImageProcessor(cornerRadius: imageView.bounds.size.width / 10)
        
        imageView.kf.indicatorType = .activity
        
        
        imageView.kf.setImage(with: url,
                              placeholder: UIImage(named: "EllipseBlur"),
                              options: [
                                .processor(processor)
                              ]) { result in
                                  switch result {
                                  case .success(let value):
                                      Logger.logMessage("Image loaded successfully", for: self, level: .info)
                                  case .failure(let error):
                                      Logger.logMessage("Image loading error: \(error.localizedDescription)", for: self, level: .error)
                                      print(url.absoluteString)
                                  }
                              }
    }
    
    @objc internal func logOutButtonTapped() {
        showConfirmationAlert()
    }
    
    private func navigateToLoginScreen() {
        guard let window = UIApplication.shared.windows.first else {
            return
        }
        
        let splashViewController = SplashViewController()
        
        // Анимация перехода
        let options: UIView.AnimationOptions = .transitionCrossDissolve
        UIView.transition(with: window, duration: 0.5, options: options, animations: {
            window.rootViewController = splashViewController
            window.makeKeyAndVisible()
            window.isUserInteractionEnabled = true
        }, completion: nil)
    }
}

extension ProfileViewController {
    
    func showConfirmationAlert() {
        let alertController = UIAlertController(title: "Пока, пока!", message: "Уверены, что хотите выйти?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.performLogout()
        }
        let noAction = UIAlertAction(title: "Нет", style: .default, handler: nil)
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func performLogout() {
        UIBlockingProgressHUD.show()
        presenter?.logout()
        ProgressHUD.dismiss()
        navigateToLoginScreen()
    }
    
}


