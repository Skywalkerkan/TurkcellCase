//
//  MovieListEntity.swift
//  TurkcellCase
//
//  Created by Erkan on 26.05.2025.
//

import Foundation

struct MovieListResponse: Codable {
    let dates: Dates?
    let page: Int?
    let results: [Movie]?
    let totalPages, totalResults: Int?

    enum CodingKeys: String, CodingKey {
        case dates, page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct Dates: Codable {
    let maximum, minimum: String?
}

struct Movie: Codable {
    let adult: Bool?
    let backdropPath: String?
    let genreIds: [Int]?
    let id: Int
    let originalTitle, overview: String?
    let popularity: Double?
    let posterPath, releaseDate, title: String?
    let video: Bool?
    let voteAverage: Double?
    let voteCount: Int?

    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case genreIds = "genre_ids"
        case id
        case originalTitle = "original_title"
        case overview, popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title, video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}
