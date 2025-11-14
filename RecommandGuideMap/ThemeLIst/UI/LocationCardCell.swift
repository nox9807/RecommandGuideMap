//
//  PlaceCardCell.swift
//  RecommandGuideMap
//
//  Created by 이찬희 on 11/10/25.
//

import UIKit

final class LocationCardCell: UICollectionViewCell {
    static let reuseID = "LocationCardCell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var metaLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!   
    @IBOutlet weak var mapButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
    
    func configure(location: Location) {
        nameLabel.text   = location.name
        ratingLabel.text = "★ \(String(format: "%.1f", location.rating))"
        metaLabel.text   = location.distanceText
        descLabel.text   = location.description
        
        // ✅ 변경: URL로만 로드
        imageView.setImage(url: location.imageURL, placeholder: UIImage(named: "placeholder"))
    }
}
