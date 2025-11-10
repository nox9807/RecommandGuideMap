//
//  PlaceCardCell.swift
//  RecommandGuideMap
//
//  Created by 이찬희 on 11/10/25.
//

import UIKit

final class PlaceCardCell: UICollectionViewCell {
    static let reuseID = "PlaceCardCell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var metaLabel: UILabel!     // 거리 · 주소 등 간단 메타
    @IBOutlet weak var descLabel: UILabel!     // 간략 소개
    @IBOutlet weak var mapButton: UIButton!
    
    var onMap: ((Place) -> Void)?
    private var currentPlace: Place?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 0      // 상세는 풀스크린 카드이므로 0
        contentView.layer.masksToBounds = true
    }
    
    func configure(place: Place) {
        currentPlace = place
        
        imageView.image   = place.photo
        nameLabel.text    = place.name
        ratingLabel.text  = "★ \(place.rating)"
        metaLabel.text    = place.distanceText
        descLabel.text    = place.description
    }
    
    @IBAction func didTapMap() {
        if let p = currentPlace { onMap?(p) }
    }
}
