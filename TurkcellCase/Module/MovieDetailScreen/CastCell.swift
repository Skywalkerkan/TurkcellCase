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
    
    private let roleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
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
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(roleLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            
            /*roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            roleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            roleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            roleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -4)*/
        ])
    }
    
    // MARK: - Configure
    
    func configure(_ cast: Cast) {
        nameLabel.text = cast.name ?? "Bilinmiyor"
        
        if let character = cast.character, !character.isEmpty {
            roleLabel.text = character
        } else if let department = cast.department?.rawValue {
            roleLabel.text = department
        } else {
            roleLabel.text = "Rol Bilinmiyor"
        }
        
        if let profilePath = cast.profilePath {
            let imageUrl = "https://image.tmdb.org/t/p/w500\(profilePath)"
            ImageLoaderManager.shared.loadImage(
                from: imageUrl,
                into: imageView,
                placeholder: UIImage(systemName: "person.fill")
            )
        } else {
            imageView.image = UIImage(systemName: "person.fill")
        }
    }
}
