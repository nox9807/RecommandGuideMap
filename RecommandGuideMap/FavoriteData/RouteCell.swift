import UIKit

class RouteCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView? // 아이콘 안 쓰면 없어도 됨
    
    func configure(with route: RouteFavorite) {
        // 제목: 출발 — 도착 (가독성 위해 en dash)
        titleLabel.text = "\(route.origin) — \(route.destination)"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        
        summaryLabel.text = route.summaryText
        summaryLabel.textColor = .secondaryLabel
        summaryLabel.font = .systemFont(ofSize: 14)
        
        accessoryType = .disclosureIndicator
        iconImageView?.image = UIImage(systemName: "bookmark") // SF Symbols 예시
    }
}

