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
    func loadMoreMoviesIfNeeded(for section: Int)
}

final class MovieListPresenter {
    
    private var moviesByCategory: [MovieCategory: [Movie]] = [:]
    private var currentPages: [MovieCategory: Int] = [:]
    private var isLoadingMore: [MovieCategory: Bool] = [:]
    
    private let interactor: MovieListInteractorProtocol
    private let router: MovieListRouterProtocol
    unowned var view: MovieListViewControllerProtocol
    
    private let sectionCategories: [MovieCategory] = [.topRated, .popularity, .revenue]
    
    init(view: MovieListViewControllerProtocol,
         interactor: MovieListInteractorProtocol,
         router: MovieListRouterProtocol) {
        
        self.view = view
        self.interactor = interactor
        self.router = router
        
        sectionCategories.forEach { category in
            currentPages[category] = 1
            isLoadingMore[category] = false
        }
        
    }}

extension MovieListPresenter: MovieListPresenterProtocol {
    
    func viewDidLoad() {
        //loading viewin aktif edilmesi ve bütün movilerin çekilmesi
        view.showLoadingView()
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
        //Section adlarını direk static verilmesi
        switch section {
        case 0: return "Popular"
        case 1: return "Top Rated"
        case 2: return "Revenue"
        default: return ""
        }
    }
    
    func didSelectMovie(_ movie: Movie) {
        router.navigate(.detail(movie: movie))
    }
    
    //pagination işleminin yapılması bir section için daha fazla verinin çekilmesi
    func loadMoreMoviesIfNeeded(for section: Int) {
        guard section < sectionCategories.count else { return }
        let category = sectionCategories[section]
        guard isLoadingMore[category] != true else { return }
        currentPages[category] = (currentPages[category] ?? 1) + 1
        let nextPage = currentPages[category] ?? 2
        isLoadingMore[category] = true
        interactor.fetchMoreMovies(category: category, page: nextPage)
    }
}

extension MovieListPresenter: MovieListInteractorOutputProtocol {
    
    func fetchAllMovieListsSuccess(_ movies: [MovieCategory: [Movie]]) {
        self.moviesByCategory = movies
        view.reloadData()
        view.hideLoadingView()
    }
    
    func fetchMoreMoviesSuccess(category: MovieCategory, movies: [Movie]) {
        if var existingMovies = moviesByCategory[category] {
            existingMovies.append(contentsOf: movies)
            moviesByCategory[category] = existingMovies
        } else {
            moviesByCategory[category] = movies
        }
        isLoadingMore[category] = false
        
        view.reloadData()
        view.hideLoadingView()
        print(" Loaded \(movies.count) more movies for \(category)")
    }
    
    func fetchMoviesFailure(_ error: NetworkError) {
        sectionCategories.forEach { category in
            isLoadingMore[category] = false
        }
        
        view.showError(error.localizedDescription)
    }
}
