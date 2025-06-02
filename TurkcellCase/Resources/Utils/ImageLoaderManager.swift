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
    private init() {
        configureSDWebImageCache()
    }
    
    //Imageların cachlenmesi için gerekli yer ama max memory cost koydum ki performans sorunları yaşatmasın
    private func configureSDWebImageCache() {
        let config = SDImageCache.shared.config
        config.shouldCacheImagesInMemory = true
        config.maxMemoryCost = 300 * 1024 * 1024
        config.maxDiskSize = 500 * 1024 * 1024
    }
    
    func loadImage(from urlString: String, into imageView: UIImageView, placeholder: UIImage? = nil) {
        guard let url = URL(string: urlString) else {
            imageView.image = placeholder
            return
        }
        
        imageView.sd_setImage(with: url, placeholderImage: placeholder)
    }
        
    func clearCache(completion: (() -> Void)? = nil) {
        SDImageCache.shared.clear(with: .all, completion: completion)
    }
}
