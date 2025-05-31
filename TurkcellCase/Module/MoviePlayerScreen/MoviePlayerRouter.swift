//
//  MoviePlayerRouter.swift
//  TurkcellCase
//
//  Created by Erkan on 31.05.2025.
//

import UIKit

protocol MoviePlayerRouterProtocol: AnyObject {
    func navigateBack()
}

final class MoviePlayerRouter {
    weak var viewController: UIViewController?
    
    static func createModule(movieURL: String) -> UIViewController {
        let view = MoviePlayerViewController()
        let router = MoviePlayerRouter()
        let interactor = MoviePlayerInteractor(movieURLString: movieURL)
        let presenter = MoviePlayerPresenter(view: view,
                                             interactor: interactor,
                                             router: router)
        
        view.presenter = presenter
        interactor.output = presenter
        router.viewController = view
        
        return view
    }
}

extension MoviePlayerRouter: MoviePlayerRouterProtocol {
    func navigateBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
