//
//  PlaceViewController.swift
//  RecommandGuideMap
//
//  Created by chaeyoonpark on 11/6/25.
//

import UIKit

class PlaceViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    /// 즐겨찾기 목록을 이 화면에서 사용하기 위한 배열
    private var places: [FavoritePlace] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate   = self
    }
    
    /// 즐겨찾기 탭으로 들어올 때마다 최신 데이터로 갱신
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // FavoriteStore에 쌓여 있는 즐겨찾기 목록 가져오기
        places = FavoriteStore.shared.places
        tableView.reloadData()
        
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
        cell.categoryLabel.text = place.categoryOrDistance
        
        cell.imageView1.image = UIImage(named: "sample1")
        cell.imageView2.image = UIImage(named: "sample2")
        cell.imageView3.image = UIImage(named: "sample3")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200  // 셀 높이 (원하면 조정 가능)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = FavoriteStore.shared.places[indexPath.row]
        
        // MapViewController 로 이동
        let storyboard = UIStoryboard(name: "Map", bundle: nil)
        guard let mapVC = storyboard.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController else { return }
        
        // SearchItem 형태로 변환 (MapViewController가 사용하는 타입)
        let item = SearchResponse.SearchItem(
            title: place.name,
            category: place.categoryOrDistance,
            address: place.address,
            roadAddress: place.address,
            mapx: String(Int(place.lng)),
            mapy: String(Int(place.lat))
        )
        
        mapVC.selectedItem = item
        
        // 전체 화면으로 띄우기
        mapVC.modalPresentationStyle = .fullScreen
        mapVC.isHiddenViews = true
        present(mapVC, animated: true)
    }
    
    
    
}

