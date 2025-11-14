//
//  ThemeCardCell.swift
//  RecommandGuideMap
//
//  Created by 이찬희 on 11/10/25.
//

import UIKit

final class ThemeCardCell: UICollectionViewCell {
    static let reuseID = "ThemeCardCell"
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowRadius  = 8
        layer.shadowOffset  = .init(width: 0, height: 4)
    }
    
    func configure(theme: Theme) {
        titleLabel.text = theme.title
        // ✅ 변경: URL로만 로드
        coverImageView.setImage(url: theme.coverURL, placeholder: UIImage(named: "placeholder"))
    }
}
