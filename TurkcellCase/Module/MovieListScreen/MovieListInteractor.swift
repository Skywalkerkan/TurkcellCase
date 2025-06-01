//
//  MovieListInteractor.swift
//  TurkcellCase
//
//  Created by Erkan on 26.05.2025.
//

import Foundation

protocol MovieListInteractorProtocol {
    func fetchAllMovies()
    func fetchMoreMovies(category: MovieCategory, page: Int)
}

protocol MovieListInteractorOutputProtocol: AnyObject {
    func fetchAllMovieListsSuccess(_ movies: [MovieCategory: [Movie]])
    func fetchMoreMoviesSuccess(category: MovieCategory, movies: [Movie])
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
            //Her bir kategoriye göre filmlerin çekilip sectionlara ayrılması
            var results: [MovieCategory: [Movie]] = [:]

            async let topRatedResult = movieService.fetchMovies(category: .topRated, page: 1)
            async let popularResult = movieService.fetchMovies(category: .popularity, page: 1)
            async let revenueResult = movieService.fetchMovies(category: .revenue, page: 1)
            
            let (topRated, popularity, revenue) = await (topRatedResult, popularResult, revenueResult)
            
            var errors: [NetworkError] = []
            
            switch topRated {
            case .success(let response): 
                results[.topRated] = response.results
            case .failure(let error): 
                errors.append(error)
            }
            
            switch popularity {
            case .success(let response): 
                results[.popularity] = response.results
            case .failure(let error): 
                errors.append(error)
            }
            
            switch revenue {
            case .success(let response): 
                results[.revenue] = response.results
            case .failure(let error):
                errors.append(error)
            }
            
            if let error = errors.first {
                self.output?.fetchMoviesFailure(error)
            } else {
                self.output?.fetchAllMovieListsSuccess(results)
            }
            
        }
    }
    
    //20den fazla film çekileceğinde kullanılan method
    func fetchMoreMovies(category: MovieCategory, page: Int) {
        Task {
            let result = await movieService.fetchMovies(category: category, page: page)
            
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let response):
                    let movies = response.results ?? []
                    self?.output?.fetchMoreMoviesSuccess(category: category, movies: movies)
                case .failure(let error):
                    self?.output?.fetchMoviesFailure(error)
                }
            }
        }
    }
}
