//
//  ViewLoad.swift
//  RecommandGuideMap
//
//  Created by 이찬희 on 11/10/25.
//

// ViewLoad.swift
import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSURL, UIImage>()
    
    func load(_ url: URL?, into imageView: UIImageView, placeholder: UIImage? = nil) {
        guard let url else { imageView.image = placeholder; return }
        if let cached = cache.object(forKey: url as NSURL) {
            imageView.image = cached
            return
        }
        imageView.image = placeholder
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, let data, let img = UIImage(data: data) else { return }
            self.cache.setObject(img, forKey: url as NSURL)
            DispatchQueue.main.async { imageView.image = img }
        }.resume()
    }
}

extension UIImageView {
    func setImage(url: URL?, placeholder: UIImage? = nil) {
        ImageLoader.shared.load(url, into: self, placeholder: placeholder)
    }
}
