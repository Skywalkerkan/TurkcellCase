//
//  MovieDetailPresenter.swift
//  TurkcellCase
//
//  Created by Erkan on 29.05.2025.
//

import Foundation

protocol MovieDetailPresenterProtocol {
    func viewDidLoad()
    var castCount: Int { get }
    func getCastMember(at index: Int) -> Cast?
    func didSelectCast(_ cast: Cast)
    func fetchCredits(for movieID: Int)
    func didSelectPlayMovie(movie: Movie?)
}

final class MovieDetailPresenter {
    
    private var cast: [Cast] = []
    
    private let interactor: MovieDetailInteractorProtocol
    private let router: MovieDetailRouterProtocol
    unowned var view: MovieDetailViewControllerProtocol
    
    init(view: MovieDetailViewControllerProtocol,
         interactor: MovieDetailInteractorProtocol,
         router: MovieDetailRouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

extension MovieDetailPresenter: MovieDetailPresenterProtocol {
    
    func viewDidLoad() {
        view.setupCollectionView()
    }
    
    func fetchCredits(for movieID: Int) {
        interactor.fetchCredits(for: movieID)
    }
    
    var castCount: Int {
        return cast.count
    }
    
    func getCastMember(at index: Int) -> Cast? {
        guard index < cast.count else { return nil }
        return cast[index]
    }
    
    func didSelectCast(_ cast: Cast) {
        print("🎭 Seçilen Oyuncu: \(cast.name ?? "-")")
    }
    
    func didSelectPlayMovie(movie: Movie?){
        router.navigate(.playMovie(movie: movie))
    }
}

extension MovieDetailPresenter: MovieDetailInteractorOutputProtocol {
    
    func fetchCreditsSuccess(_ credits: MovieCredit) {
        self.cast = credits.cast ?? []
        view.reloadData()
    }
    
    func fetchCreditsFailure(_ error: NetworkError) {
        view.showError(error.localizedDescription)
    }
}
