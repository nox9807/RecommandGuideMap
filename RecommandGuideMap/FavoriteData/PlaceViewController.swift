//
//  PlaceViewController.swift
//  RecommandGuideMap
//
//  Created by chaeyoonpark on 11/6/25.
//

import UIKit

class PlaceViewController: UIViewController {
    
        
    @IBOutlet weak var tableView: UITableView!
    
    // 임시 데이터 (나중에 Core Data 연결되면 실제 데이터로 바뀜)
    let places: [(name: String, address: String, category: String)] = [
        ("카페 노티드", "서울 강남구 테헤란로 123", "카페 · 0.5km"),
        ("을지로 식당", "서울 중구 을지로 45", "한식 · 2.1km"),
        ("올리브영 강남점", "서울 강남구 강남대로 101", "쇼핑 · 0.8km")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        
    }
}

extension PlaceViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as? PlaceCell else {
            return UITableViewCell()
        }
        
        let place = places[indexPath.row]
        cell.nameLabel.text = place.name
        cell.addressLabel.text = place.address
        cell.categoryLabel.text = place.category
        
        cell.imageView1.image = UIImage(named: "sample1")
        cell.imageView2.image = UIImage(named: "sample2")
        cell.imageView3.image = UIImage(named: "sample3")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200  // 셀 높이 (원하면 조정 가능)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "RouteDetailViewController")
                as? RouteDetailViewController else { return }
        
        vc.route = RouteDummyData.samples[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

    
    
}

