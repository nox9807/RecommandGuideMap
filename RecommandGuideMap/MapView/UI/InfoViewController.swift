//
//  InfoViewController.swift
//  RecommandGuideMap
//
//  Created by JaeYeongMAC on 11/11/25.
//

import UIKit

class InfoViewController: UIViewController {
    
    var item: SearchResponse.SearchItem?
    var onDirectRequest: ((SearchResponse.SearchItem) -> Void)?
    var mapView: MapViewController!
    
    @IBOutlet weak var placeTextLabel: UILabel!
    @IBOutlet weak var addressTextLabel: UILabel!
    
    @IBAction func startButton(_ sender: Any) {
        guard let item else { return }
        onDirectRequest?(item)
        
        presentStartDirectionView()
    }
    
    @IBAction func arriveButton(_ sender: Any) {
        guard let item else { return }
        onDirectRequest?(item)
        
        presentArriveDirectionView()
    }
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        guard let item else { return }
        FavoriteStore.shared.add(from: item)
        // 간단한 알림 띄우기
        let alert = UIAlertController(title: "즐겨찾기 추가",
                                      message: "즐겨찾기에 저장되었습니다.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIUpdate()
    }
    
    func presentStartDirectionView() {
        let directionVC = storyboard?.instantiateViewController(identifier: "DirectionsViewController") as! DirectionsViewController
        directionVC.modalPresentationStyle = .overFullScreen
        directionVC.startItem = item
        directionVC.mapView = mapView
        present(directionVC, animated: true)
    }
    
    func presentArriveDirectionView() {
        let directionVC = storyboard?.instantiateViewController(identifier: "DirectionsViewController") as! DirectionsViewController
        directionVC.modalPresentationStyle = .overFullScreen
        directionVC.arriveItem = item
        directionVC.mapView = mapView
        present(directionVC, animated: true)
    }
    
    // MARK: 텍스트 업데이트 메소드
    func UIUpdate() {
        guard let item else { return }
        placeTextLabel.text = stripHTML(item.title)
        addressTextLabel.text = item.roadAddress.isEmpty ? item.address : item.roadAddress
    }
}
