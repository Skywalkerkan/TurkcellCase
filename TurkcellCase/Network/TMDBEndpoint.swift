//
//  TMDBEndpoint.swift
//  TurkcellCase
//
//  Created by Erkan on 26.05.2025.
//

import Foundation

enum MovieCategory: String {
    case nowPlaying = "now_playing"
    case popular = "popular"
    case topRated = "top_rated"
    case upcoming = "upcoming"
}

enum SortOption: String {
    case popularity = "popularity.desc"
    case topRated = "vote_average.desc"
    case revenue = "revenue.desc"
    case releaseDate = "release_date.desc"
}


enum MovieEndpoint {
    case movieList(category: MovieCategory, page: Int)
    case discoverList(sortBy: SortOption, page: Int)    // /discover/movie?sort_by=...
    case movieDetail(id: Int)
    case movieCredits(id: Int)

    var baseURL: String {
        return "https://api.themoviedb.org/3"
    }
    
    var path: String {
        switch self {
        case .movieList(let category, _):
            return "/movie/\(category.rawValue)"
        case .discoverList:
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
        case .movieList(_, let page),
             .discoverList(_, let page):
            items.append(URLQueryItem(name: "page", value: "\(page)"))
        case .movieDetail:
            break
        case .movieCredits(id: let id):
            break
        }
        return items
    }
    
    var headers: [String: String]? {
        return ["Accept": "application/json"]
    }
}
