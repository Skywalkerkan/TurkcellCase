//
//  LoadingCell.swift
//  TurkcellCase
//
//  Created by Erkan on 28.05.2025.
//

import UIKit

final class LoadingCell: UICollectionViewCell {
    static let identifier = "LoadingCell"
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(style: .large)
        activityView.hidesWhenStopped = true
        activityView.color = .systemBlue
        activityView.translatesAutoresizingMaskIntoConstraints = false
        return activityView
    }()
    
    private let denemeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Yükleniyor..."
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(activityIndicator)
        contentView.addSubview(denemeLabel)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            denemeLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 8),
            denemeLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    func startLoading() {
        activityIndicator.startAnimating()
    }
    
    func stopLoading() {
        activityIndicator.stopAnimating()
    }
}
