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

final class MovieListRouter {
    
    weak var viewController: MovieListViewController?
    var detailRouterFactory: ((Movie) -> MovieDetailViewController?)?
    
}

extension MovieListRouter: MovieListRouterProtocol {
    
    func navigate(_ route: MovieRoutes) {
        guard case .detail(let movie) = route else { return }
        
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            //Telefonlar için
            if let detailVC = detailRouterFactory?(movie) {
                viewController?.navigationController?.pushViewController(detailVC, animated: true)
            }
            return
        }
        //Tablet için gerekli yandan gelen view
        viewController?.showOverlayDetail(with: movie)
    }
}

