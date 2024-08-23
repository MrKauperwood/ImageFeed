//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 23.8.2024.
//

import Foundation

protocol ProfilePresenterProtocol{
    var view: ProfileControllerProtocol? { get set }
    func viewDidLoad()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    weak var view: ProfileControllerProtocol?
    
    private let profileService = ProfileService.shared
    
    
    func viewDidLoad() {
        if let profile = profileService.profile {
            view?.updateUserInfo(usingDataFrom: profile)
        }
    }
    
    
}
