//
//  MovieDetailAssembly.swift
//  TurkcellCase
//
//  Created by Erkan on 1.06.2025.
//

import Foundation
import Swinject

final class MovieDetailAssembly: Assembly {
    
    func assemble(container: Container) {
        
        container.register(MovieDetailInteractorProtocol.self) { resolver in
            let service = resolver.resolve(MovieServiceProtocol.self)!
            let interactor = MovieDetailInteractor(movieService: service)
            return interactor
        }
        
        container.register(MovieDetailRouterProtocol.self) { _ in
            MovieDetailRouter()
        }
        
        container.register(MovieDetailPresenterProtocol.self) { (resolver, view: MovieDetailViewControllerProtocol) in
            let interactor = resolver.resolve(MovieDetailInteractorProtocol.self)!
            let router = resolver.resolve(MovieDetailRouterProtocol.self)!
            
            let presenter = MovieDetailPresenter(
                view: view,
                interactor: interactor,
                router: router
            )
            
            if let interactor = interactor as? MovieDetailInteractor {
                interactor.output = presenter
            }
            
            return presenter
        }
        
        container.register(MovieDetailViewController.self) { (resolver, movie: Movie) in
            let viewController = MovieDetailViewController()
            viewController.movie = movie
            
            let presenter = resolver.resolve(MovieDetailPresenterProtocol.self, argument: viewController as MovieDetailViewControllerProtocol)
            viewController.presenter = presenter
            
            if let router = resolver.resolve(MovieDetailRouterProtocol.self) as? MovieDetailRouter {
                router.viewController = viewController
            }
            
            return viewController
        }
    }
}
