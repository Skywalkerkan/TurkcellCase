//
//  MovieListRouter.swift
//  TurkcellCase
//
//  Created by Erkan on 26.05.2025.
//


import UIKit

enum MovieRoutes {
    case detail(movie: Movie)
}

protocol MovieListRouterProtocol {
    func navigate(_ route: MovieRoutes)
}

final class MovieRouter {
    
    weak var viewController: MovieListViewController?
    private var detailViewController: MovieDetailViewController?
    private var isDetailVisible = false
    private var detailLeadingConstraint: NSLayoutConstraint?
    
    static func createModule() -> MovieListViewController {
        let view = MovieListViewController()
        let router = MovieRouter()
        let interactor = MovieListInteractor()
        let presenter = MovieListPresenter(view: view, interactor: interactor, router: router)
        
        view.presenter = presenter
        interactor.output = presenter
        router.viewController = view
        
        return view
    }
}

extension MovieRouter: MovieListRouterProtocol {
    
    func navigate(_ route: MovieRoutes) {
        guard case .detail(let movie) = route else { return }
        
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            let detailVC = MovieDetailViewController()
            detailVC.movie = movie
            viewController?.navigationController?.pushViewController(detailVC, animated: true)
            return
        }
        
        viewController?.showOverlayDetail(with: movie)
    }
    
}
