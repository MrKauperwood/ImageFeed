//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 30.7.2024.
//

import Foundation

class ImagesListService {
    
    // MARK: - Public Properties
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    private(set) var photos: [Photo] = []
    
    // MARK: - Private Properties
    private var lastLoadedPage = 0
    private let amountPerPage = 10
    private let urlSession = URLSession.shared
    
    var task: URLSessionTask?
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
                print("Failed to load photos: \(error)")
                completion(.failure(error))
            }
            
            task?.resume()
            print("Get photos request task started")
            
            
        }
        
    }
    
    // MARK: - Private Methods
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
                print("Failed to create get photos URL from components")
                return nil
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            print("Get photos request created: \(request)")
            return request
        }
    
}
