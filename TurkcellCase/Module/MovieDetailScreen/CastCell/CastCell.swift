//
//  CastCell.swift
//  TurkcellCase
//
//  Created by Erkan on 28.05.2025.
//

import UIKit

class CastCell: UICollectionViewCell {
        
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = UIColor.systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            
        ])
    }
    
    func configure(_ cast: Cast) {
        nameLabel.text = cast.name ?? "Unknown"
        
        if let profilePath = cast.profilePath {
            let imageUrl = "https://image.tmdb.org/t/p/w500\(profilePath)"
            ImageLoaderManager.shared.loadImage(
                from: imageUrl,
                into: imageView,
                placeholder: UIImage(systemName: "person.fill")?
                    .withRenderingMode(.alwaysOriginal)
                    .withTintColor(.systemGray4)
            )
        } else {
            imageView.image = UIImage(systemName: "person.fill")
        }
    }
}
