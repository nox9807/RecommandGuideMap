//
//  ViewController.swift
//  RecommandGuideMap
//
//  Created by JaeYeongMAC on 11/5/25.
//

import UIKit
import MapKit
import NMapsMap

class MapViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let manager = CLLocationManager()
    var isFollowingUser: Bool = true
    //var items: [SearchResponse.SearchItem] = []
    var selectedItem: SearchResponse.SearchItem?
    // 기존 mapView만으로 지도를 구현했는데 showLoactionButton이 NMFNaverMapView에서만 제공되는 API라 NMFNaverMapView를 루트로 쓰고 내부의 실제 지도는 mapView: NMFMapView로 읽기 전용 계산 프로퍼티로 기존코드를 그대로 사용
    private var naverMapView: NMFNaverMapView!
    private var mapView: NMFMapView { naverMapView.mapView }
    private var marker: NMFMarker?
    private var locationOverlay: NMFLocationOverlay!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.distanceFilter = 5
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        
        // MARK: mapView에 지도 표시 및 위치 표시 버튼
        naverMapView = NMFNaverMapView(frame: view.bounds)
        naverMapView.showLocationButton = true
        naverMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(naverMapView)
        view.sendSubviewToBack(naverMapView)
        
        mapView.positionMode = .normal
        
        locationOverlay = mapView.locationOverlay
        locationOverlay.hidden = false
        
        searchBar.backgroundImage = UIImage()
        //searchBar.delegate = self
    }
    
    // MARK: -검색창을 띄워주고 검색했을 때 그 좌표에 focuse하고 모달표시
    func presentSearch() {
        let vc = storyboard?.instantiateViewController(identifier: "SearchViewController") as! SearchViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.onSelect = { [weak self] item in
            guard let self = self else { return }
            
            self.selectedItem = item
            
            self.presentedViewController?.dismiss(animated: true) {
                self.focus(mapx: item.mapx, mapy: item.mapy, title: item.title)
                
                self.performSegue(withIdentifier: "ShowBottomSheet", sender: self)
            }
        }
        present(vc, animated: true)
    }
    
    // MARK: - 좌표를 받아 카메라 업데이트 및 마커 표시, 마커 핸들러
    func focus(mapx: String, mapy: String, title: String) {
        guard let x = tm128Double(from: mapx),
              let y = tm128Double(from: mapy) else { return }
        
        isFollowingUser = false
        
        let latLng = NMGLatLng(lat: y, lng: x)
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: latLng)
        cameraUpdate.animation = .easeIn
        mapView.moveCamera(cameraUpdate)
        
        marker?.mapView = nil
        let m = NMFMarker(position: latLng)
        m.captionText = stripHTML(title)
        
        m.touchHandler = { [weak self] overlay -> Bool in
            guard let self = self, let tapped = overlay as? NMFMarker else { return false }
            
            tapped.zIndex = 1000
            
            self.performSegue(withIdentifier: "ShowBottomSheet", sender: self)
            return true
        }
        
        m.mapView = mapView
        marker = m
    }
    
    // MARK: - 좌표값 문자열을 소수로 치환하는 메소드
    func tm128Double(from raw: String, Digits: Int = 7) -> Double? {
        let digits = raw.filter(\.isNumber)
        guard !digits.isEmpty else { return nil }
        
        if digits.count <= Digits {
            let frac = String(repeating: "0", count: Digits - digits.count) + digits
            return Double("0.\(frac)")
        } else {
            let splitIdx = digits.index(digits.endIndex, offsetBy: -Digits)
            let frontPart = String(digits[..<splitIdx])
            let backPart = String(digits[splitIdx...])
            
            return Double("\(frontPart).\(backPart)")
        }
    }
    
    // MARK: - 알림 표시(위치 서비스를 비활성화 했을 때)
    func showAlert() {
        let alert = UIAlertController(title: "알림", message: "위치 서비스를 활성화 시켜주세요", preferredStyle: .alert)
        
        let settingAction = UIAlertAction(title: "설정", style: .default) { _ in
            // 설정으로 바로 이동
            if let url = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        }
        alert.addAction(settingAction)
        
        let cancleAction = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(cancleAction)
        
        
        present(alert, animated: true)
    }
    
    // MARK: - 반 모달시트 구현
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowBottomSheet" else { return }
        
        let destVC = segue.destination
        
        destVC.modalPresentationStyle = .pageSheet
        
        if let sheet = destVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .medium
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }
            //destVC.isModalInPresentation = true
        (destVC as? InfoViewController)?.item = selectedItem
    }
}

// MARK: - CLLocationManagerDelegate 구현
extension MapViewController: CLLocationManagerDelegate {
    // MARK: 상태 변경시 작동하는 코드
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(#function, manager.authorizationStatus.rawValue)
        switch manager.authorizationStatus {
            case .notDetermined: // 허가 상태 결정 안됨(설치 후 첫 실행)
                manager.requestWhenInUseAuthorization()
            case .restricted: // 금지됨
                showAlert()
            case .denied: // 거부됨
                showAlert()
            case .authorizedAlways:
                break
            case .authorizedWhenInUse:
                manager.startUpdatingLocation() //시제로 위치정보를 요청하는 메소드
            @unknown default:
                break
        }
    }
    
    // MARK: 현재위치를 가져오는 메소드
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last else { return }
        let coord = last.coordinate
        let target = NMGLatLng(lat: coord.latitude, lng: coord.longitude)
        print("메소드")
        DispatchQueue.main.async {
            self.locationOverlay.location = target
            print(self.locationOverlay.location)
            guard self.isFollowingUser else { return }
            
            let cameraUpdate = NMFCameraUpdate(scrollTo: target)
            cameraUpdate.animation = .easeIn
            self.mapView.moveCamera(cameraUpdate)
        }
    }
    
    // MARK: FailError 표시
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        // 무시해도되는 에러때문에 이걸로 무시하게해줘야함.
        let error = error as NSError
        guard error.code != CLError.Code.locationUnknown.rawValue else { return }
        
        print(error)
        manager.stopUpdatingLocation()
    }
}

// MARK: - UISearchBarDelegate구현
extension MapViewController: UISearchBarDelegate {
    // editing을 false로 만들고 서치바를 누르면 서치페이지가 프레젠트되게함
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        presentSearch()
        return false
    }
}

// MARK: - 카메라가 왜 움직였는지 이유에 따라 isFollowingUser를 ture/false로 하기 위해 구현
extension MapViewController: NMFMapViewCameraDelegate {
    func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
        switch reason {
            case NMFMapChangedByGesture:
                isFollowingUser = false
            case NMFMapChangedByControl:
                if mapView.positionMode == .normal || mapView.positionMode == .direction || mapView.positionMode == .compass {
                    isFollowingUser = true
                }
            default:
                break
        }
    }
}
