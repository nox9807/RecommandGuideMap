import UIKit



class RouteViewController: UIViewController {
    
    var route: RouteSummary!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var routes: [RouteSummary] = RouteDummyData.samples
    
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
        
        print("선택한 route.title =", routes[indexPath.row].title)

        navigationController?.pushViewController(vc, animated: true)
    }

}
