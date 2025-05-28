//
//  MovieListInteractor.swift
//  TurkcellCase
//
//  Created by Erkan on 26.05.2025.
//

import Foundation

protocol MovieListInteractorProtocol {
    func fetchAllMovies()
}

protocol MovieListInteractorOutputProtocol: AnyObject {
    func fetchAllMovieListsSuccess(_ movies: [MovieCategory: [Movie]])
    func fetchMoviesFailure(_ error: NetworkError)
}

final class MovieListInteractor {
    weak var output: MovieListInteractorOutputProtocol?
    
    private let movieService: MovieServiceProtocol
    
    init(movieService: MovieServiceProtocol = TMDBService()) {
        self.movieService = movieService
    }
}

extension MovieListInteractor: MovieListInteractorProtocol {
    
    func fetchAllMovies() {
        Task {
            var results: [MovieCategory: [Movie]] = [:]
            
            async let topRatedResult = movieService.fetchMovies(category: .topRated, page: 1)
            async let upcomingResult = movieService.fetchMovies(category: .upcoming, page: 1)
            async let nowPlayingResult = movieService.fetchMovies(category: .nowPlaying, page: 1)
            
            let (topRated, upcoming, nowPlaying) = await (topRatedResult, upcomingResult, nowPlayingResult)
            
            var errors: [NetworkError] = []
            
            switch topRated {
            case .success(let response): results[.topRated] = response.results
            case .failure(let error): errors.append(error)
            }
            
            switch upcoming {
            case .success(let response): results[.upcoming] = response.results
            case .failure(let error): errors.append(error)
            }
            
            switch nowPlaying {
            case .success(let response): results[.nowPlaying] = response.results
            case .failure(let error): errors.append(error)
            }
            
            DispatchQueue.main.async { [weak self] in
                if let error = errors.first {
                    self?.output?.fetchMoviesFailure(error)
                } else {
                    self?.output?.fetchAllMovieListsSuccess(results)
                }
            }
        }
    }
}
