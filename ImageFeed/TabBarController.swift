//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 23.7.2024.
//

import UIKit
import Foundation

final class TabBarController: UITabBarController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        // Инициализация ImageListViewController
        guard let imageListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else {
            Logger.logMessage("Failed to cast to type ImagesListViewController", for: self, level: .error)
            return
        }
        
        let imageListViewPresenter = ImagesListPresenter()
        imageListViewController.presenter = imageListViewPresenter
        imageListViewPresenter.view = imageListViewController
        
        imageListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil
        )
        
        let profilePresenter = ProfilePresenter()
        let profileViewController = ProfileViewController()
        
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil)
        
        
        self.viewControllers = [imageListViewController, profileViewController]
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.barTintColor = UIColor.ypBlack
        tabBar.backgroundColor = UIColor.ypBlack
        tabBar.isTranslucent = false
    }
}
