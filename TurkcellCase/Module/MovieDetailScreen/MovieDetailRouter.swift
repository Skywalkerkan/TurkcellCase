//
//  MovieDetailRouter.swift
//  TurkcellCase
//
//  Created by Erkan on 29.05.2025.
//

import UIKit

enum MovieDetailRoutes {
    case playMovie(movie: Movie?)
}

protocol MovieDetailRouterProtocol {
    func navigate(_ route: MovieDetailRoutes)
}

final class MovieDetailRouter {
    
    weak var viewController: MovieDetailViewController?
    
}

extension MovieDetailRouter: MovieDetailRouterProtocol {
    
    func navigate(_ route: MovieDetailRoutes) {
        switch route {
        case .playMovie(let movie):
            let playerVC = AssemblyManager.shared.container.resolve(
                MoviePlayerViewController.self,
                arguments: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
                movie
            )!
            playerVC.modalPresentationStyle = .fullScreen
            viewController?.present(playerVC, animated: true)
        }
    }
}
