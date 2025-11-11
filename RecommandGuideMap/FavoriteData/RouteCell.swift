import UIKit

class RouteCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView? // 아이콘 안 쓰면 없어도 됨
    
    // RouteCell.swift
    func configure(with route: RouteSummary) {
        titleLabel.text = route.title
        summaryLabel.text = route.summaryText
    }
}

