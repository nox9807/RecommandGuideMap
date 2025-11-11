import UIKit



class RouteViewController: UIViewController {
    
    var route: RouteSummary!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var routes: [RouteSummary] = [
        RouteSummary(
            title: "강원도 해안 루트",
            origin: RoutePlace(name: "강원도 심곡리", lat: 37.68, lng: 129.04),
            waypoints: [],
            destination: RoutePlace(name: "정동진 호텔", lat: 37.689, lng: 129.034),
            categoryCounts: ["관광명소":3, "식당":2, "숙박":1]
        ),
        RouteSummary(
            title: "서울 중심 투어",
            origin: RoutePlace(name: "홍대입구", lat: 37.556, lng: 126.923),
            waypoints: [],
            destination: RoutePlace(name: "남산 타워", lat: 37.551, lng: 126.988),
            categoryCounts: ["관광명소":2, "식당":1, "숙박":0]
        )
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
        
        let storyboard = UIStoryboard(name: "Favorite", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "RouteDetailViewController")
                as? RouteDetailViewController else { return }
        
        vc.route = routes[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

}
