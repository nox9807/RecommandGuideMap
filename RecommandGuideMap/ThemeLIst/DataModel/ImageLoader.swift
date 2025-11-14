//
//  ImageLoader.swift
//  RecommandGuideMap
//
//  Created by 이찬희 on 11/10/25.
//

import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSURL, UIImage>()
    
    func load(_ urlString: String, into imageView: UIImageView, placeholder: UIImage? = nil) {
        imageView.image = placeholder
        
        guard let url = URL(string: urlString) else { return }
        
        if let cached = cache.object(forKey: url as NSURL) {
            imageView.image = cached
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data) else {
                if let error = error {
                    print("⚠️ 이미지 로드 실패: \(error.localizedDescription)")
                }
                return
            }
            
            self.cache.setObject(image, forKey: url as NSURL)
            
            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
    }
}
extension UIImageView {
    func setImage(url: String, placeholder: UIImage? = nil) {
        ImageLoader.shared.load(url, into: self, placeholder: placeholder)
    }
}
