//
//  MovieCell.swift
//  TurkcellCase
//
//  Created by Erkan on 27.05.2025.
//

import UIKit
import SDWebImage

final class MovieCell: UICollectionViewCell {
    static let identifier = "MovieCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("fatal error") }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.sd_cancelCurrentImageLoad()
        imageView.image = nil
    }
    
    
    func configure(with movie: Movie) {
        let baseURL = "https://image.tmdb.org/t/p/w500"
        if let posterPath = movie.posterPath {
            let fullURL = baseURL + posterPath
            ImageLoaderManager.shared.loadImage(
                from: fullURL,
                into: imageView,
                placeholder: UIImage(systemName: "film.circle")?.withRenderingMode(.alwaysOriginal)
                    .withTintColor(.systemGray4))
        } else {
            imageView.image = UIImage(systemName: "film")
        }
    }
}
