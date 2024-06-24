//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 20.5.2024.
//

import Foundation
import UIKit

final class ProfileViewController: UIViewController {
    
    var imageView : UIImageView!
    let profileImage = UIImage(named: "Photo")
    var userNameLabel : UILabel!
    var nickNameLabel : UILabel!
    var descriptionLabel : UILabel!
    
    
    var button : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = profileImage
        imageView.tintColor = .gray
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
        
        userNameLabel = UILabel()
        userNameLabel.text = "Екатерина Новикова"
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.textColor = .ypWhite
        userNameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        
        view.addSubview(userNameLabel)
        NSLayoutConstraint.activate([
            userNameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            userNameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
        ])
        
        nickNameLabel = UILabel()
        nickNameLabel.text = "@ekaterina_nov"
        nickNameLabel.textColor = .ypGrey
        nickNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        nickNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nickNameLabel)
        NSLayoutConstraint.activate([
            nickNameLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8),
            nickNameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
        ])
        
        descriptionLabel = UILabel()
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
        ])
        
        
        button = UIButton()
        let buttonImage = UIImage(systemName: "ipad.and.arrow.forward")
        button = UIButton.systemButton(with: buttonImage!, target: self, action: #selector(buttonTapped))
        button.tintColor = .ypRed
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 25),
            button.heightAnchor.constraint(equalToConstant: 25),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
    
    @objc func buttonTapped() {
        print("Button was tapped")
    }
}
