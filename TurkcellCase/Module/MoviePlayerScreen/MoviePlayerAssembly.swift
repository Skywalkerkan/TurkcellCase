//
//  MoviePlayerAssembly.swift
//  TurkcellCase
//
//  Created by Erkan on 1.06.2025.
//

import Foundation
import Swinject

final class MoviePlayerAssembly: Assembly {
    
    func assemble(container: Container) {
        
        container.register(MoviePlayerInteractorProtocol.self) { (_, movieURL: String) in
            MoviePlayerInteractor(movieURLString: movieURL)
        }
        
        container.register(MoviePlayerRouterProtocol.self) { _ in
            MoviePlayerRouter()
        }
        
        container.register(MoviePlayerPresenterProtocol.self) { (resolver,
                                                                 view: MoviePlayerViewControllerProtocol,
                                                                 movieURL: String) in
            let interactor = resolver.resolve(MoviePlayerInteractorProtocol.self,
                                              argument: movieURL)!
            let router     = resolver.resolve(MoviePlayerRouterProtocol.self)!
            
            let presenter  = MoviePlayerPresenter(view: view,
                                                  interactor: interactor,
                                                  router: router)
            if let interactor = interactor as? MoviePlayerInteractor {
                interactor.output = presenter
            }
            return presenter
        }
        
        container.register(MoviePlayerViewController.self) { (resolver,
                                                              movieURL: String,
                                                              movie: Movie?) in
            let vc = MoviePlayerViewController()
            vc.movie = movie
            
            vc.presenter = resolver.resolve(
                MoviePlayerPresenterProtocol.self,
                arguments: vc as MoviePlayerViewControllerProtocol,
                           movieURL
            )
            
            if let router = resolver.resolve(MoviePlayerRouterProtocol.self) as? MoviePlayerRouter {
                router.viewController = vc
            }
            return vc
        }
    }
}
