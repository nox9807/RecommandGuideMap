import UIKit

// 더미 모델 (나중에 팀원 데이터로 교체 예정)
struct RouteFavorite {
    let origin: String
    let destination: String
    let categoryCounts: [String:Int] // 예: ["관광명소":3, "식당":2, "숙박":1]
    
    var summaryText: String {
        // 0개는 표시 생략
        categoryCounts
            .filter { $0.value > 0 }
            .sorted { $0.key < $1.key } // 보기 좋게 정렬(선택)
            .map { "\($0.key) \($0.value)개" }
            .joined(separator: " · ")
    }
}

class RouteViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    //  더미 데이터 (나중에 Store에서 주입받을 예정)
    private var routes: [RouteFavorite] = [
        RouteFavorite(origin: "강원도 심곡리", destination: "정동진 호텔",
                      categoryCounts: ["관광명소":3, "식당":2, "숙박":1]),
        RouteFavorite(origin: "홍대입구", destination: "남산 타워",
                      categoryCounts: ["관광명소":2, "식당":1, "숙박":0]),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.rowHeight  = 76 // 필요시 조절
    }
}

extension RouteViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        routes.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RouteCell",
                                                       for: indexPath) as? RouteCell else {
            return UITableViewCell()
        }
        cell.configure(with: routes[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: 상세 보기로 push/present
    }
}
