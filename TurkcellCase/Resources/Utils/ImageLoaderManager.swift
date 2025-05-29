//
//  ImageLoaderManager.swift
//  TurkcellCase
//
//  Created by Erkan on 29.05.2025.
//

import UIKit
import SDWebImage

final class ImageLoaderManager {
    
    static let shared = ImageLoaderManager()
    private init() {}
    
    func loadImage(from urlString: String, into imageView: UIImageView, placeholder: UIImage? = nil) {
        guard let url = URL(string: urlString) else {
            imageView.image = placeholder
            return
        }
        
        imageView.sd_setImage(with: url, placeholderImage: placeholder)
    }
    
    func loadImage(from urlString: String, into imageView: UIImageView, placeholder: UIImage? = nil, completion: ((UIImage?) -> Void)? = nil) {
        guard let url = URL(string: urlString) else {
            imageView.image = placeholder
            completion?(nil)
            return
        }
        
        imageView.sd_setImage(with: url, placeholderImage: placeholder) { image, _, _, _ in
            completion?(image)
        }
    }
    
    func clearCache(completion: (() -> Void)? = nil) {
        SDImageCache.shared.clear(with: .all, completion: completion)
    }
}
