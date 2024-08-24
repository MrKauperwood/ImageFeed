//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 24.8.2024.
//

import Foundation

protocol ImagesListPresenterProtocol{
    var view: ImagesListControllerProtocol? { get set }
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListControllerProtocol?
    
    
}

