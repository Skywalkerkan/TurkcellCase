//
//  LoadingShowable.swift
//  TurkcellCase
//
//  Created by Erkan on 26.05.2025.
//

import UIKit

protocol LoadingShowable where Self: UIViewController {
    func showLoading()
    func hideLoading()
}

//Loading ekranını ekranda protocolle miras alıp kolaty bir şekilde atanıp gösterilmesi
extension LoadingShowable {
    func showLoading() {
        LoadingView.shared.startLoading()
    }

    func hideLoading() {
        LoadingView.shared.hideLoading()
    }
}
