//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 23.8.2024.
//

import Foundation
import Kingfisher

protocol ProfilePresenterProtocol{
    var view: ProfileControllerProtocol? { get set }
    func viewDidLoad()
    func logout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileControllerProtocol?
    
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        setUpCacheSettings()
        if let profile = profileService.profile {
            view?.updateUserInfo(usingDataFrom: profile)
        }
        setupAvatarObserver()
    }
    
    func logout() {
        ProfileLogoutService.shared.logout()
    }
    
    private func setupAvatarObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateAvatarIfPossible()}
        
        updateAvatarIfPossible()
    }
    
    private func updateAvatarIfPossible() {
        guard
            let profileImageURL = ProfileImageService.shared.userImage?.profile_image.medium,
            let url = URL(string: profileImageURL)
        else { return }
        
        view?.updateAvatar(url: url)
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
    
    
}
