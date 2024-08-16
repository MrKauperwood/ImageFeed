//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 18.7.2024.
//

import Foundation

final class ProfileImageService {
    
    // MARK: - Private Properties
    private let urlSession  = URLSession.shared
    private static let baseUrl = "https://api.unsplash.com/users/"
    private let storage = OAuth2TokenActions()
    
    private var task: URLSessionTask?
    private(set) var userImage: UserResult?
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    // MARK: - Singleton Instance
    static let shared = ProfileImageService()
    
    // MARK: - Private Initializer
    private init() {}
    
    struct UserResult: Codable {
        let profile_image: ImageUrls
    }
    
    struct ImageUrls: Codable {
        let small : String
        let medium : String
    }
    
    enum AuthServiceError: Error {
        case invalidRequest
        case tokenIsNil
    }
    
    func clearUserImage() {
        self.userImage = nil
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if task != nil {
            task?.cancel()
        }
        
        guard let token = storage.getTokenFromStorage() else {
            completion(.failure(AuthServiceError.tokenIsNil))
            return
        }
        
        guard let request = makeGetPublicInfoRequest(with: token, username : username) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task = urlSession.objectTask(for: request, isSnakeCaseConvertNeeded: false) {[weak self] (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                defer {
                    self?.task = nil
                }
                
                switch result {
                case .success(let response):
                    let imageUrl = response.profile_image.small
                    self?.userImage = response
                    completion(.success(imageUrl))
                case .failure(let error):
                    Logger.logMessage("ProfileImageService: Network or decoding error: \(error.localizedDescription)", for: "ProfileImageService", level: .error)
                    completion(.failure(error))
                }
            }
        }
        
        
        task?.resume()
        Logger.logMessage("Get user info request task started", for: self, level: .info)
    }
    
    // MARK: - Private Methods
    private func makeGetPublicInfoRequest(with token: String, username : String) -> URLRequest? {
        guard let urlComponents = URLComponents(string: Self.baseUrl + username),
              let url = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        Logger.logMessage("Get user info request created: \(request)", for: self, level: .info)
        return request
        
    }
    
}
