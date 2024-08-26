//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 24.8.2024.
//

import Foundation

protocol ImagesListPresenterProtocol{
    var view: ImagesListControllerProtocol? { get set }
    var photos: [Photo] { get }
    
    func loadInitialPhotos(completion: @escaping () -> Void)
    func loadMorePhotosIfNeeded(for: Int)
    func toggleLike(at index: Int, completion: @escaping (Result<Bool, Error>) -> Void)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListControllerProtocol?
    
    private(set) var photos: [Photo] = []
    private var isLoadingNewPhotos = false
    private var storage = OAuth2TokenActions()
    private var imageListService = ImagesListService()
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(photosDidChange),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
    }
    
    // Добавляем существующие фотографии из ImageListService в массив photos презентера
    func loadExistingPhotos() {
        self.photos = imageListService.getPhotos()
    }
    
    @objc private func photosDidChange() {
        loadExistingPhotos()
        view?.updateTableViewAnimated()
    }
    
    func loadInitialPhotos(completion: @escaping () -> Void) {
        view?.showLoadingIndicator()
        
        if isLoadingNewPhotos || !photos.isEmpty {
            completion()
            return
        }
        
        isLoadingNewPhotos = true
        
        guard let token = storage.getTokenFromStorage() else {
            Logger.logMessage("Failed to retrieve token", for: self, level: .error)
            completion()
            return
        }
        
        imageListService.fetchPhotosNextPage(token: token) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoadingNewPhotos = false // Сбрасываем флаг после завершения загрузки
                self.view?.hideLoadingIndicator()
                switch result {
                case .success(let message):
                    self.loadExistingPhotos()
                    Logger.logMessage("Success: \(message)", for: self, level: .info)
                    
                case .failure(let error):
                    Logger.logMessage("Error: \(error.localizedDescription)", for: self, level: .error)
                }
                completion()
            }
        }
    }
    
    func loadMorePhotosIfNeeded(for index: Int) {
        // Проверяем, нужно ли загружать больше фотографий
        if index + 1 == photos.count && !isLoadingNewPhotos {
            
            guard let token = storage.getTokenFromStorage() else {
                Logger.logMessage("Failed to retrieve token", for: self, level: .error)
                return
            }
            
            isLoadingNewPhotos = true
            
            imageListService.fetchPhotosNextPage(token: token) { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoadingNewPhotos = false
                    
                    switch result {
                    case .success(let newPhotos):
                        Logger.logMessage("Success: \(newPhotos)", for: self, level: .info)
                        self.loadExistingPhotos()
                        self.view?.updateTableView()
                    case .failure(let error):
                        Logger.logMessage("Error: \(error.localizedDescription)", for: self, level: .error)
                    }
                }
            }
        }
    }
    
    func toggleLike(at index: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        let photo = photos[index]
        
        guard let token = storage.getTokenFromStorage() else {
            Logger.logMessage("Failed to retrieve token", for: self, level: .error)
            completion(.failure(NSError(domain: "TokenError", code: 0, userInfo: nil)))
            return
        }
        
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked, token: token) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.photos[index].isLiked.toggle()
                    completion(.success(self.photos[index].isLiked))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}

