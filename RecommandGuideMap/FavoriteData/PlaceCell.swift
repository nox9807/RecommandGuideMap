//
//  PlaceCell.swift
//  RecommandGuideMap
//
//  Created by chaeyoonpark on 11/7/25.
//

import UIKit

class PlaceCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!        // 가게 이름
    @IBOutlet weak var addressLabel: UILabel!     // 주소
    @IBOutlet weak var categoryLabel: UILabel!    // 카테고리/거리 등
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 셀 초기 설정 (선택사항)
        selectionStyle = .none
    }
}

