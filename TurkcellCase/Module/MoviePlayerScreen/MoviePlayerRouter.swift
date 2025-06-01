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

}

extension MoviePlayerRouter: MoviePlayerRouterProtocol {
    
    func navigateBack() {
        viewController?.dismiss(animated: true)
    }
    
}
