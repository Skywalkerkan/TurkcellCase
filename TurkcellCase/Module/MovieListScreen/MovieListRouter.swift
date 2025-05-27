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
        switch route {
        case .detail(let movie):
            DispatchQueue.main.async {
                print(movie)
                //let detailVC = MovieDetailRouter.createModule(movie: movie)
               // self.viewController?.navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
}
