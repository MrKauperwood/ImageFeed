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

final class ProfileViewController: UIViewController {
    
    // MARK: - Private Properties
    private let profileService = ProfileService.shared
    
    private let profileImage = UIImage()
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = profileImage
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        imageView.tintColor = .gray
        return imageView
    }()
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Алексей Бонд"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .ypWhite
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        return label
    }()
    
    private lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "@lexabond"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .ypGrey
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .ypWhite
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private lazy var button: UIButton = {
        let buttonImage = UIImage(systemName: "ipad.and.arrow.forward")
        let button = UIButton.systemButton(with: buttonImage!, target: self, action: #selector(buttonTapped))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .ypRed
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        
        if let profile = profileService.profile {
            updateUserInfo(usingDataFrom: profile)
        }
        
        setupUI()
        setUpCacheSettings()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateAvatar()
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
    
    private func updateUserInfo(usingDataFrom profile : ProfileService.Profile) {
        userNameLabel.text = profile.name
        nickNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    private func setUpCacheSettings() {
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = 300 * 1024 * 1024
        cache.memoryStorage.config.countLimit = 150
        cache.diskStorage.config.sizeLimit = 1000 * 1000 * 1000
        cache.memoryStorage.config.expiration = .seconds(600)
        cache.diskStorage.config.expiration = .never
        cache.memoryStorage.config.cleanInterval = 30
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.userImage?.profile_image.medium,
            let url = URL(string: profileImageURL)
        else { return }
        
        let processor = DownsamplingImageProcessor(size: imageView.bounds.size)
        |> RoundCornerImageProcessor(cornerRadius: 20)
        
        imageView.kf.indicatorType = .activity
        
        
        imageView.kf.setImage(with: url,
                              placeholder: UIImage(named: "EllipseBlur"),
                              options: [
                                .processor(processor)
                              ]) { result in
                                  switch result {
                                  case .success(let value):
                                      print(value.image)
                                      print(value.cacheType)
                                      print(value.source)
                                  case .failure(let error):
                                      print(error)
                                  }
                              }
    }
    
    @objc private func buttonTapped() {
        print("Button was tapped")
        UIBlockingProgressHUD.show()
        ProfileLogoutService.shared.logout()
        ProgressHUD.dismiss()
        navigateToLoginScreen()
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
        }, completion: nil)
    }
}
