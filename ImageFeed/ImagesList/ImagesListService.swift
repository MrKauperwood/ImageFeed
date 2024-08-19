//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 30.7.2024.
//

import Foundation

final class ImagesListService {
    
    // MARK: - Public Properties
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    private(set) var photos: [Photo] = []
    
    // MARK: - Private Properties
    private var lastLoadedPage = -1
    private let amountPerPage = 10
    private let urlSession = URLSession.shared
    
    var task: URLSessionTask?
    var changeLikeTask: URLSessionTask?
    
    enum SortingType: String {
        case latest
        case oldest
        case popular
    }
    
    enum AuthServiceError: Error {
        case invalidRequest
    }
    
    // MARK: - Public Methods
    public func fetchPhotosNextPage(token: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard task == nil else {
            return
        }
        
        let nextPage = lastLoadedPage + 1
        
        guard let request = makeGetPhotosRequest(
            forPage: nextPage,
            per_page: amountPerPage,
            order_by: SortingType.latest.rawValue,
            token: token
        ) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task = urlSession.objectTask(for: request, isSnakeCaseConvertNeeded: true) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            
            defer {
                self.task = nil
            }
            
            switch result {
            case .success(let photoResults):
                guard !photoResults.isEmpty else {
                    // Если ответ пустой, остановить загрузку
                    completion(.success("No more photos to load"))
                    return
                }
                
                // Преобразуем PhotoResult в Photo
                let newPhotos = photoResults.map { Photo(from: $0) }
                
                // Обновляем массив фотографий на главном потоке
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                    completion(.success("Successfully loaded photos"))
                }
                
            case .failure(let error):
                Logger.logMessage("Failed to load photos: \(error)", for: self, level: .error)
                completion(.failure(error))
            }
            
            task?.resume()
            Logger.logMessage("Get photos request task started", for: self, level: .info)
            
            
        }
        
    }
    
    
    func changeLike(photoId: String, isLike: Bool, token: String, _ completion: @escaping (Result<Void, Error>) -> Void) {
        // Отменяем предыдущую задачу, если она еще выполняется
        changeLikeTask?.cancel()
        
        assert(Thread.isMainThread)
        
        defer {
            self.task = nil
        }
        
        guard let request = makeChangeLikeRequest(forPhotoWithId: photoId, isLike: isLike, token: token) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        changeLikeTask = urlSession.dataTask(with: request) { data, response, error in
            defer {
                self.changeLikeTask = nil
            }
            
            if let error = error {
                Logger.logMessage("Failed to \(isLike ? "Like" : "Unlike") photos: \(error)", for: self, level: .error)
                completion(.failure(error))
            } else {
                Logger.logMessage("Successfully \(isLike ? "Liked" : "Unliked") photo", for: self, level: .info)
                self.updateLikeButton(photoId: photoId)
                completion(.success(()))
            }
        }
        
        changeLikeTask?.resume()
        Logger.logMessage("\(isLike ? "Like" : "Unlike") request task started", for: self, level: .info)
    }
    
    // MARK: - Private Methods
    private func updateLikeButton(photoId: String) {
        if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
            // Текущий элемент
            let photo = self.photos[index]
            // Копия элемента с инвертированным значением isLiked.
            let newPhoto = Photo(
                id: photo.id,
                size: photo.size,
                createdAt: photo.createdAt,
                welcomeDescription: photo.welcomeDescription,
                thumbImageURL: photo.thumbImageURL,
                smallImageURL: photo.smallImageURL,
                largeImageURL: photo.largeImageURL,
                isLiked: !photo.isLiked
            )
            // Заменяем элемент в массиве.
            self.photos[index] = newPhoto
        }
    }
    
    private func makeGetPhotosRequest(
        forPage page: Int,
        per_page: Int,
        order_by : String,
        token: String) -> URLRequest? {
            
            var urlComponents = URLComponents(string: Constants.getPhotosURL.absoluteString)
            
            urlComponents?.queryItems = [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "per_page", value: String(per_page)),
                URLQueryItem(name: "order_by", value: order_by)
            ]
            
            guard let url = urlComponents?.url else {
                Logger.logMessage("Failed to create get photos URL from components", for: self, level: .error)
                return nil
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            Logger.logMessage("Get photos request created: \(request)", for: self, level: .info)
            
            return request
        }
    
    private func makeChangeLikeRequest(
        forPhotoWithId photoId: String,
        isLike: Bool,
        token: String) -> URLRequest? {
            
            let urlComponents = URLComponents(string: Constants.getChangeLikePhotoURL(for: photoId).absoluteString)
            guard let url = urlComponents?.url else {
                Logger.logMessage("Failed to create change like for photo URL from components", for: self, level: .error)
                return nil
            }
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            request.httpMethod = isLike ? "POST" : "DELETE"
            Logger.logMessage("\(isLike ? "Like" : "Unlike") photo request created: \(request)",
                                          for: self,
                                          level: .info)
            
            return request
            
        }
    
    func clearImagesList() {
        photos.removeAll()
        lastLoadedPage = 0 // Сбрасываем номер страницы, чтобы начать заново
        Logger.logMessage("Images list cleared", for: self, level: .info)
    }
    
}
