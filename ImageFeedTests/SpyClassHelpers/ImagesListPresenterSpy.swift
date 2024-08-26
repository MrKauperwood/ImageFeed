//
//  ImagesListPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Aleksei Bondarenko on 24.8.2024.
//

import Foundation
@testable import ImageFeed
import CoreGraphics

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListControllerProtocol?
    
    var photos: [Photo] = []
    
    var loadInitialPhotosCalled = false
    var loadMorePhotosIfNeededCalled = false
    var toggleLikeCalled = false
    
    func loadInitialPhotos(completion: @escaping () -> Void) {
        loadInitialPhotosCalled = true
        completion()
    }
    
    func loadMorePhotosIfNeeded(for index: Int) {
        loadMorePhotosIfNeededCalled = true
    }
    
    func toggleLike(at index: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        toggleLikeCalled = true
        photos[index].isLiked.toggle() // Переключаем состояние лайка
        completion(.success(photos[index].isLiked))
    }
}
