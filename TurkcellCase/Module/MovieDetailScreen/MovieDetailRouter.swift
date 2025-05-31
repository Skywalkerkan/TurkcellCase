//
//  MovieDetailRouter.swift
//  TurkcellCase
//
//  Created by Erkan on 29.05.2025.
//

import UIKit

enum MovieDetailRoutes {
    case castDetail(cast: Cast)
    case playMovie(videoID: String)
}

protocol MovieDetailRouterProtocol {
    func navigate(_ route: MovieDetailRoutes)
}

final class MovieDetailRouter {
    
    weak var viewController: MovieDetailViewController?
    
    static func createModule(with movie: Movie) -> MovieDetailViewController {
        let view = MovieDetailViewController()
        let router = MovieDetailRouter()
        let interactor = MovieDetailInteractor()
        let presenter = MovieDetailPresenter(view: view, interactor: interactor, router: router)
        
        view.presenter = presenter
        view.movie = movie
        interactor.output = presenter
        router.viewController = view
        
        return view
    }
}

extension MovieDetailRouter: MovieDetailRouterProtocol {
    
    func navigate(_ route: MovieDetailRoutes) {
        switch route {
        case .castDetail(let cast):
            let castDetailVC = MoviePlayerViewController()
            /*CastDetailVC.cast = cast*/
            viewController?.navigationController?.pushViewController(castDetailVC, animated: true)
            
        case .playMovie(let videoID):
            //let playerVC = MoviePlayerViewController()
            /*playerVC.videoID = videoID
            viewController?.present(playerVC, animated: true, completion: nil)*/
            let playerVC = MoviePlayerRouter.createModule(movieURL: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8")
            viewController?.navigationController?.pushViewController(playerVC, animated: true)
        }
    }
}
