//
//  BaseViewController.swift
//  TurkcellCase
//
//  Created by Erkan on 26.05.2025.
//

import UIKit

class BaseViewController: UIViewController, LoadingShowable {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showAlert(with title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

}
