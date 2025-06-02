//
//  MovieListAssembly.swift
//  TurkcellCase
//
//  Created by Erkan on 01.06.2025.
//

import Foundation
import Swinject

final class MovieListAssembly: Assembly {
    //Movielist için assemble classı
    func assemble(container: Container) {
        
        container.register(MovieServiceProtocol.self) { _ in
            TMDBService()
        }.inObjectScope(.container)
        
        container.register(MovieListInteractorProtocol.self) { resolver in
            let interactor = MovieListInteractor(
                movieService: resolver.resolve(MovieServiceProtocol.self)!
            )
            return interactor
        }
        
        container.register(MovieListRouterProtocol.self) { resolver in
            let router = MovieListRouter()
            router.detailRouterFactory = { movie in
                return resolver.resolve(MovieDetailViewController.self, argument: movie)
            }
            return router
        }
        
        container.register(MovieListPresenterProtocol.self) { (resolver, view: MovieListViewControllerProtocol) in
            let interactor = resolver.resolve(MovieListInteractorProtocol.self)!
            let router = resolver.resolve(MovieListRouterProtocol.self)!
            
            let presenter = MovieListPresenter(
                view: view,
                interactor: interactor,
                router: router
            )
            
            if let movieInteractor = interactor as? MovieListInteractor {
                movieInteractor.output = presenter
            }
            
            return presenter
        }
        
        container.register(MovieListViewController.self) { resolver in
            let vc = MovieListViewController()

            vc.presenter = resolver.resolve(
                MovieListPresenterProtocol.self,
                argument: vc as MovieListViewControllerProtocol
            )

            vc.detailViewFactory = { movie in
                resolver.resolve(MovieDetailViewController.self, argument: movie)
            }

            if let router = resolver.resolve(MovieListRouterProtocol.self) as? MovieListRouter {
                router.viewController = vc
            }
            return vc
        }

        registerMovieDetailModule(container: container)
    }
    
    private func registerMovieDetailModule(container: Container) {
        container.register(MovieDetailViewController.self) { (resolver, movie: Movie) in
            let viewController = MovieDetailViewController()
            return viewController
        }
    }
}

extension Container {
    
    func getMovieListViewController() -> MovieListViewController {
        return self.resolve(MovieListViewController.self)!
    }
}
