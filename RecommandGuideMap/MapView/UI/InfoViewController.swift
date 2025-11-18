//
//  InfoViewController.swift
//  RecommandGuideMap
//
//  Created by JaeYeongMAC on 11/11/25.
//

import UIKit

/// 특정 장소(검색 결과)를 보여주고
/// - 즐겨찾기 추가
/// - 출발지/도착지로 설정하여 길찾기 화면으로 이동을 담당하는 하단 시트 화면.
class InfoViewController: UIViewController {
    
    /// MapViewController에서 넘겨받은 검색 결과 아이템.
    var item: SearchResponse.SearchItem?
    /// 출발/도착 버튼을 눌렀을 때 상위에서 추가 동작을 수행하고 싶을 때 사용하는 콜백.
    var onDirectRequest: ((SearchResponse.SearchItem) -> Void)?
    
    /// 실제 지도를 갖고 있는 상위 MapViewController.
    /// 길찾기 화면을 띄울 때 함께 전달된다.
    var mapView: MapViewController!
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var placeTextLabel: UILabel!
    @IBOutlet weak var addressTextLabel: UILabel!
    
    /// "출발" 버튼 탭 시 호출.
    /// 선택한 장소를 출발지로 설정한 뒤 길찾기 화면을 띄운다.
    @IBAction func startButton(_ sender: Any) {
        guard let item else { return }
        onDirectRequest?(item)
        
        presentStartDirectionView()
    }
    
    /// "도착" 버튼 탭 시 호출.
    /// 선택한 장소를 도착지로 설정한 뒤 길찾기 화면을 띄운다.
    @IBAction func arriveButton(_ sender: Any) {
        guard let item else { return }
        onDirectRequest?(item)
        
        presentArriveDirectionView()
    }
    
    /// "즐겨찾기" 버튼 탭 시 호출.
    /// 선택한 장소를 `FavoriteStore`에 추가하고 알림을 띄운다.
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
    
    // MARK: - Present Directions
    
    /// 현재 아이템을 출발지로 설정한 길찾기 화면을 모달로 띄운다.
    func presentStartDirectionView() {
        let directionVC = storyboard?.instantiateViewController(identifier: "DirectionsViewController") as! DirectionsViewController
        directionVC.modalPresentationStyle = .overFullScreen
        directionVC.startItem = item
        directionVC.mapView = mapView
        present(directionVC, animated: true)
    }
    
    /// 현재 아이템을 도착지로 설정한 길찾기 화면을 모달로 띄운다.
    func presentArriveDirectionView() {
        let directionVC = storyboard?.instantiateViewController(identifier: "DirectionsViewController") as! DirectionsViewController
        directionVC.modalPresentationStyle = .overFullScreen
        directionVC.arriveItem = item
        directionVC.mapView = mapView
        present(directionVC, animated: true)
    }
    
    // MARK: - UI
    
    /// `item`을 사용해서 라벨 텍스트를 갱신한다.
    /// 도로명 주소가 비어 있으면 지번 주소를 대신 사용한다.
    func UIUpdate() {
        guard let item else { return }
        placeTextLabel.text = stripHTML(item.title)
        addressTextLabel.text = item.roadAddress.isEmpty ? item.address : item.roadAddress
    }
}
