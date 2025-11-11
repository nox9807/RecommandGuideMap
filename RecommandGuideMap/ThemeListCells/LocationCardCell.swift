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
    
    var onMap: ((Location) -> Void)?
    private var currentPlace: Location?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 0
        contentView.layer.masksToBounds = true
    }
    
    func configure(location: Location) {
        currentPlace = location
        
        imageView.image   = location.photo
        nameLabel.text    = location.name
        ratingLabel.text  = "★ \(location.rating)"
        metaLabel.text    = location.distanceText
        descLabel.text    = location.description
    }
    
    @IBAction func didTapMap() {
        if let p = currentPlace { onMap?(p) }
    }
}
