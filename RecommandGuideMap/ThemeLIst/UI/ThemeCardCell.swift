/// [feat] 테마 카드 셀 구현
/// - Theme의 썸네일 이미지와 타이틀을 카드 형태로 표시
/// - 그림자/코너 둥글기 적용으로 리스트 UI 강화
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

        coverImageView.setImage(url: theme.coverURL, placeholder: UIImage(named: "placeholder"))
    }
}
