//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 7.7.2024.
//

import Foundation

final class OAuth2Service {
    
    // MARK: - Public Properties
    static let shared  = OAuth2Service()
    enum AuthServiceError: Error {
        case invalidRequest
    }
    
    // MARK: - Private Properties
    private let urlSession  = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    
    // MARK: - Initializers
    private init() {}
    
    // MARK: - Public Methods
    func fetchOAuthToken(code : String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        lastCode = code
        
        guard let request = makeTokenRequest(with: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task = urlSession.objectTask(for: request, isSnakeCaseConvertNeeded: true) {[weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                defer {
                    self?.task = nil
                    self?.lastCode = nil
                }
                
                switch result {
                case .success(let responseBody):
                    Logger.logMessage("Successfully received token: \(responseBody.accessToken)", for: self, level: .info)
                    completion(.success(responseBody.accessToken))
                case .failure(let error):
                    Logger.logMessage("OAuth2Service: Network or decoding error: \(error.localizedDescription)", for: self, level: .error)
                    completion(.failure(error))
                }
            }
        }
        
        task?.resume()
        Logger.logMessage("Token request task started", for: self, level: .info)

    }
    
    // MARK: - Private Methods
    private func makeTokenRequest(with code: String) -> URLRequest? {
        var urlComponents = URLComponents(string: Constants.getTokenURL.absoluteString)
        
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents?.url else {
            Logger.logMessage("Failed to create URL from components", for: self, level: .error)
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        Logger.logMessage("Token request created: \(request)", for: self, level: .info)
        
        return request
    }
}
