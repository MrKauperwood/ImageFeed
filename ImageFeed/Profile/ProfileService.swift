//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 17.7.2024.
//

import Foundation

final class ProfileService {
    
    // MARK: - Private Properties
    private let urlSession  = URLSession.shared
    private static let baseUrl = "https://api.unsplash.com"
    private static let profileInfoUrl = baseUrl + "/me"
    
    private var task: URLSessionTask?
    private var lastToken: String?
    
    private(set) var profile: Profile?
    
    enum AuthServiceError: Error {
        case invalidRequest
    }
    
    
    struct ProfileResult: Codable {
        let id: String
        let username: String?
        let first_name: String
        let last_name: String?
        let bio: String?
    }
    
    struct Profile: Codable {
        let username: String
        let name: String
        let loginName: String
        let bio: String?
        
        init(from profileResult: ProfileResult) {
            self.username = profileResult.username ?? ""
            self.name = profileResult.first_name + " " + (profileResult.last_name ?? "")
            self.loginName = "@" + self.username
            self.bio = profileResult.bio
        }
    }
    
    // MARK: - Singleton Instance
    static let shared = ProfileService()
    
    // MARK: - Private Initializer
    private init() {}
    
    // MARK: - Public Methods
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if task != nil {
            if lastToken != token {
                task?.cancel()
            } else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastToken == token {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        
        lastToken = token
        
        guard let request = makeGetProfileInfoRequest(with: token) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task = urlSession.objectTask(for: request, isSnakeCaseConvertNeeded: false) {[weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                defer {
                    self?.task = nil
                    self?.lastToken = nil
                }
                
                switch result {
                case .success(let response):
                    Logger.logMessage("Successfully received profile info for user with username: \(response.username)", for: "ProfileService", level: .info)
                    let profile = Profile(from: response)
                    self?.profile = profile
                    completion(.success(profile))
                case .failure(let error):
                    Logger.logMessage("Network or decoding error: \(error.localizedDescription)", for: "ProfileService", level: .error)
                    completion(.failure(error))
                }
            }
        }
        
        task?.resume()
        Logger.logMessage("Get user info request task started", for: self, level: .info)
        
    }
    
    // MARK: - Private Methods
    private func makeGetProfileInfoRequest(with token: String) -> URLRequest? {
        guard let urlComponents = URLComponents(string: Self.profileInfoUrl),
              let url = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        Logger.logMessage("Get user info request created: \(request)", for: self, level: .info)
        return request
        
    }
    
    func clearProfile() {
        self.profile = nil
    }
    
}

