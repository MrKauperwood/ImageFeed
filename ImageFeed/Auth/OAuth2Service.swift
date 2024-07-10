//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 7.7.2024.
//

import Foundation

final class OAuth2Service {
    static let shared  = OAuth2Service()
    private init() {
    }
    
    func fetchOAuthToken(code : String, completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let request = makeTokenRequest(with: code) else {
            let error = NSError(domain: "OAuth2", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid access token request"])
            print("Error: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        print("Fetching OAuth token with request: \(request)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Network error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data,
                  let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                let error = NSError(domain: "OAuth2", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid get access token response"])
                DispatchQueue.main.async {
                    print("Service error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                if let accessToken = json?["access_token"] as? String {
                    DispatchQueue.main.async {
                        print("Successfully received token: \(accessToken)")
                        completion(.success(accessToken))
                    }
                } else {
                    let error = NSError(domain: "OAuth2", code: -1, userInfo: [NSLocalizedDescriptionKey: "No access token"])
                    DispatchQueue.main.async {
                        print("Service error: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("Decoding error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
        print("Token request task started")
        
    }
    
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
            print("Failed to create URL from components")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        print("Token request created: \(request)")
        
        return request
        
    }
}
