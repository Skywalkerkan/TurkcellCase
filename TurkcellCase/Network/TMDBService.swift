//
//  TMDBService.swift
//  TurkcellCase
//
//  Created by Erkan on 26.05.2025.
//

import Foundation

protocol MovieServiceProtocol {
    func fetchMovies(category: MovieCategory, page: Int) async -> Result<MovieListResponse, NetworkError>
    func fetchMovieDetail(movieID: Int) async -> Result<Movie, NetworkError>
}

final class TMDBService: MovieServiceProtocol {
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService = APIClient()) {
        self.networkService = networkService
    }
    
    func fetchMovies(category: MovieCategory, page: Int) async -> Result<MovieListResponse, NetworkError> {
        await networkService.request(MovieEndpoint.movieList(category: category, page: page), responseType: MovieListResponse.self)
    }
    
    func fetchMovieDetail(movieID: Int) async -> Result<Movie, NetworkError> {
        await networkService.request(MovieEndpoint.movieDetail(id: movieID), responseType: Movie.self)
    }
}
