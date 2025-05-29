//
//  MovieDetailInteractor.swift
//  TurkcellCase
//
//  Created by Erkan on 29.05.2025.
//

import Foundation

protocol MovieDetailInteractorProtocol {
    func fetchCredits(for movieID: Int)
}

protocol MovieDetailInteractorOutputProtocol: AnyObject {
    func fetchCreditsSuccess(_ credits: MovieCredit)
    func fetchCreditsFailure(_ error: NetworkError)
}

final class MovieDetailInteractor {
    weak var output: MovieDetailInteractorOutputProtocol?
    
    private let movieService: MovieServiceProtocol
    
    init(movieService: MovieServiceProtocol = TMDBService()) {
        self.movieService = movieService
    }
}

extension MovieDetailInteractor: MovieDetailInteractorProtocol {
    
    func fetchCredits(for movieID: Int) {
        Task {
            let result = await movieService.fetchMovieCredits(movieID: movieID)
            
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let credits):
                    self?.output?.fetchCreditsSuccess(credits)
                case .failure(let error):
                    self?.output?.fetchCreditsFailure(error)
                }
            }
        }
    }
}
