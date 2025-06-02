//
//  BaseViewController.swift
//  TurkcellCase
//
//  Created by Erkan on 26.05.2025.
//

import UIKit

class BaseViewController: UIViewController, LoadingShowable {
    //base view controller oluşturarak loading showabledan protokol alıp kolay bir şekilde show alertin ya da loading ekranının ekranda gösterilmesi
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
