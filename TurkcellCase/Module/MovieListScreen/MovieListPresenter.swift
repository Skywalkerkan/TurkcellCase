//
//  MovieListPresenter.swift
//  TurkcellCase
//
//  Created by Erkan on 27.05.2025.
//

import Foundation

protocol MovieListPresenterProtocol {
    func viewDidLoad()
    var sectionCount: Int { get }
    func getMoviesForSection(_ section: Int) -> [Movie]
    func getMovieCount(for section: Int) -> Int
    func getSectionTitle(for section: Int) -> String
    func didSelectMovie(_ movie: Movie)
}

final class MovieListPresenter {
    
    private var moviesByCategory: [MovieCategory: [Movie]] = [:]
    private let interactor: MovieListInteractorProtocol
    private let router: MovieListRouterProtocol
    unowned var view: MovieListViewControllerProtocol
    
    private let sectionCategories: [MovieCategory] = [.topRated, .upcoming, .nowPlaying]
    
    init(view: MovieListViewControllerProtocol, interactor: MovieListInteractorProtocol, router: MovieListRouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

extension MovieListPresenter: MovieListPresenterProtocol {
    
    func viewDidLoad() {
        
        view.setupCollectionView()
        interactor.fetchAllMovies()
        view.reloadData()
    }
    
    var sectionCount: Int {
        return sectionCategories.count
    }
    
    func getMoviesForSection(_ section: Int) -> [Movie] {
        guard section < sectionCategories.count else { return [] }
        let category = sectionCategories[section]
        return moviesByCategory[category] ?? []
    }
    
    func getMovieCount(for section: Int) -> Int {
        return getMoviesForSection(section).count
    }
    
    func getSectionTitle(for section: Int) -> String {
        switch section {
        case 0: return "Top Rated"
        case 1: return "Upcoming"
        case 2: return "Now Playing"
        default: return ""
        }
    }
    
    func didSelectMovie(_ movie: Movie) {
        router.navigate(.detail(movie: movie))
    }
}

extension MovieListPresenter: MovieListInteractorOutputProtocol {
    
    func fetchAllMovieListsSuccess(_ movies: [MovieCategory: [Movie]]) {
        self.moviesByCategory = movies
        view.reloadData()
    }

    
    func fetchMoviesFailure(_ error: NetworkError) {
        view.showError(error.localizedDescription)
    }
}
