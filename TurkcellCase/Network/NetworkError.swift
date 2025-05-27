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
            return "Geçersiz URL"
        case .requestFailed(let code, let message):
            return "İstek başarısız (\(code)): \(message ?? "Bilinmeyen hata")"
        case .decodingFailed(let error):
            return "Decoding hatası: \(error.localizedDescription)"
        case .unknown(let error):
            return "Bilinmeyen hata: \(error.localizedDescription)"
        case .noData:
            return "Veri bulunamadı."
        }
    }
}
