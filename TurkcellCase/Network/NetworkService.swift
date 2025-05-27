//
//  NetworkService.swift
//  TurkcellCase
//
//  Created by Erkan on 26.05.2025.
//

import Foundation

protocol NetworkService {
    func request<T: Decodable>(_ endpoint: MovieEndpoint, responseType: T.Type) async -> Result<T, NetworkError>
}

final class APIClient: NetworkService {
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    func request<T: Decodable>(_ endpoint: MovieEndpoint, responseType: T.Type) async -> Result<T, NetworkError> {
        guard var components = URLComponents(string: endpoint.baseURL + endpoint.path) else {
            return .failure(.invalidURL)
        }
        
        components.queryItems = endpoint.queryItems
        
        guard let url = components.url else {
            return .failure(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        
        if let headers = endpoint.headers {
            headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.requestFailed(statusCode: -1, message: nil))
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                let message = String(data: data, encoding: .utf8)
                return .failure(.requestFailed(statusCode: httpResponse.statusCode, message: message))
            }
            
            let decoded = try decoder.decode(T.self, from: data)
            return .success(decoded)
        } catch let error as DecodingError {
            print(error)
            return .failure(.decodingFailed(error))
        } catch {
            return .failure(.unknown(error))
        }
    }
}
