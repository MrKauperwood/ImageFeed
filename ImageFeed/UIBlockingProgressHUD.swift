//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 16.7.2024.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.colorHUD = .darkGray
        ProgressHUD.colorAnimation = .white
        ProgressHUD.animate()
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
    
}
