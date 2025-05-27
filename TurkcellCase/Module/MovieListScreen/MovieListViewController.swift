//
//  ViewController.swift
//  TurkcellCase
//
//  Created by Erkan on 26.05.2025.
//

import UIKit

final class MovieListViewController: BaseViewController {
    
    private let movieService: MovieServiceProtocol = TMDBService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        Task {
            await fetchMovies()
        }
    }
    
    private func fetchMovies() async {
        let result = await movieService.fetchMovies(category: .upcoming, page: 1)
        
        switch result {
        case .success(let movieListResponse):
            print(" \(movieListResponse)")
            movieListResponse.results?.forEach { movie in
                print("🎬 \(movie.title ?? "title yok")")
            }
        case .failure(let error):
            print("❌ Hata: \(error.localizedDescription)")
        }
    }
}
