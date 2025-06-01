//
//  NetworkError.swift
//  TurkcellCase
//
//  Created by Erkan on 26.05.2025.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case requestFailed(statusCode: Int, message: String?)
    case decodingFailed(DecodingError)
    case unknown(Error)
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Unknown URL"
        case .requestFailed(let code, let message):
            return "Failed Request (\(code)): \(message ?? "Unknown Error")"
        case .decodingFailed(let error):
            return "Decoded Error: \(error.localizedDescription)"
        case .unknown(let error):
            return "Unknown Error: \(error.localizedDescription)"
        case .noData:
            return "No Data."
        }
    }
}
