//
//  TMDBEndpoint.swift
//  TurkcellCase
//
//  Created by Erkan on 26.05.2025.
//

import Foundation


enum MovieCategory: String {
    case popularity = "popularity.desc"
    case topRated = "vote_count.desc"
    case revenue = "revenue.desc"
}

enum MovieEndpoint {
    case movieList(category: MovieCategory, page: Int)
    case movieDetail(id: Int)
    case movieCredits(id: Int)

    var baseURL: String {
        return "https://api.themoviedb.org/3"
    }
    
    var path: String {
        switch self {
        case .movieList:
            return "/discover/movie"
        case .movieDetail(let id):
            return "/movie/\(id)"
        case .movieCredits(let id):
            return "/movie/\(id)/credits"
        }
    }
    
    var method: String { "GET" }
    
    var queryItems: [URLQueryItem] {
        var items = [
            URLQueryItem(name: "api_key", value: APIKey.value)
        ]
        switch self {
        case .movieList(let category, let page):
            items.append(URLQueryItem(name: "sort_by", value: category.rawValue))
            items.append(URLQueryItem(name: "page", value: "\(page)"))
        case .movieDetail:
            break
        case .movieCredits(id: _):
            break
        }
        return items
    }
    
    var headers: [String: String]? {
        return ["Accept": "application/json"]
    }
}
