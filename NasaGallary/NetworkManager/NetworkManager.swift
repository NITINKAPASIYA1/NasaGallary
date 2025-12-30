//
//  NetworkManager.swift
//  NasaGallary
//
//  Created by Nitin Kapasiya on 29/12/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case noData
    case decodingFailed
    case serverError(Int)
}

class NetworkService {
    private let apiKey = "6o5bSCHZ4nhTaaUQocBQf3cA2vyh4aixnqSHN60R"
    private let baseURL = "https://api.nasa.gov/planetary/apod"
    private let maxRetryCount = 2
    
    func fetchAPOD(
        for date: Date? = nil,
        retryCount: Int = 0,
        completion: @escaping (Result<NasaStuffModel, NetworkError>) -> Void
    ) {
        guard var components = URLComponents(string: baseURL) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            queryItems.append(
                URLQueryItem(name: "date", value: formatter.string(from: date))
            )
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                if retryCount < self.maxRetryCount {
                    self.fetchAPOD(
                        for: date,
                        retryCount: retryCount + 1,
                        completion: completion
                    )
                } else {
                    completion(.failure(.requestFailed))
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(.serverError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let model = try JSONDecoder().decode(NasaStuffModel.self, from: data)
                completion(.success(model))
            } catch {
                completion(.failure(.decodingFailed))
            }
            
        }.resume()
    }
}
