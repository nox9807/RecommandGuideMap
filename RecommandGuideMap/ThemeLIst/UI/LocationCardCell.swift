//
//  LocationCardCell.swift
//  RecommandGuideMap
//

import UIKit

protocol LocationCardCellDelegate: AnyObject {
    func locationCardCellDidTapFavorite(_ cell: LocationCardCell)
    func locationCardCellDidTapMap(_ cell: LocationCardCell)
}

final class LocationCardCell: UICollectionViewCell {
    static let reuseID = "LocationCardCell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var metaLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    weak var delegate: LocationCardCellDelegate?
    private var currentLocation: Location?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
    
    func configure(location: Location) {
        currentLocation = location
        
        nameLabel.text   = location.name
        ratingLabel.text = "★ \(String(format: "%.1f", location.rating))"
        metaLabel.text   = location.distanceText
        descLabel.text   = location.description
        
        imageView.setImage(url: location.imageURL,
                           placeholder: UIImage(named: "placeholder"))
    }
    
    @IBAction func mapButtonTapped(_ sender: UIButton) {
        delegate?.locationCardCellDidTapMap(self)
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        delegate?.locationCardCellDidTapFavorite(self)   // ⭐ ThemeDetailVC로 전달
    }
}
