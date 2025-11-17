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
    @IBOutlet weak var directionButton: UIButton!
    @IBOutlet weak var xmarkButton: UIButton!
    
    @IBAction func xmarkButton(_ sender: Any) {
        dismiss(animated: true)
    }
    let manager = CLLocationManager()
    var isFollowingUser: Bool = true
    var isHiddenViews = false
    var selectedItem: SearchResponse.SearchItem?
    // 기존 mapView만으로 지도를 구현했는데 showLoactionButton이 NMFNaverMapView에서만 제공되는 API라 NMFNaverMapView를 루트로 쓰고 내부의 실제 지도는 mapView: NMFMapView로 읽기 전용 계산 프로퍼티로 기존코드를 그대로 사용
    private var naverMapView: NMFNaverMapView!
    private var mapView: NMFMapView { naverMapView.mapView }
    private var marker: NMFMarker?
    private var locationOverlay: NMFLocationOverlay!
    
    private var markers: [NMFMarker] = []
    private var paths: [NMFPath] = []
    
    
    @IBAction func vtn(_ sender: Any) {
        clearMap()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isHiddenViews {
            searchBar.isHidden = true
            directionButton.isHidden = true
            xmarkButton.isHidden = false
        }
        
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let item = selectedItem {
            focus(mapx: item.mapx, mapy: item.mapy, title: item.title)
            performSegue(withIdentifier: "ShowBottomSheet", sender: self)
            print("string")
        }
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
    
    func clearMap() {
        // 모든 마커 제거
        for marker in markers {
            marker.mapView = nil
        }
        markers.removeAll()
        
        // 모든 경로 제거
        for path in paths {
            path.mapView = nil
        }
        paths.removeAll()
    }
    
    // 출발지와 도착지를 입력하게되면 좌표를 받아서 카메라 업데이트 및 마커표시와 경로표시
    func mapViewFocus(points: [(mapx: String, mapy: String, title: String)]) {
        
        clearMap()
        
        var latLngPoints: [NMGLatLng] = []
        for point in points {
            if let latLng = addMarker(mapx: point.mapx, mapy: point.mapy, title: point.title) {
                latLngPoints.append(latLng)
            }
        }
        
        guard latLngPoints.count >= 2 else { return }
        
        let lats = latLngPoints.map { $0.lat }
        let lngs = latLngPoints.map { $0.lng }
        
        let bound = NMGLatLngBounds(
            southWest: NMGLatLng(lat: lats.min() ?? 0, lng: lngs.min() ?? 0),
            northEast: NMGLatLng(lat: lats.max() ?? 0, lng: lngs.max() ?? 0)
        )
        
        let cameraUpdate = NMFCameraUpdate(fit: bound, padding: 100)
        cameraUpdate.animation = .easeIn
        mapView.moveCamera(cameraUpdate)
        
        drawPath(points: latLngPoints)
    }
    // 경로 표시
    func drawPath(points: [NMGLatLng]) {
        guard points.count >= 2 else { return }
        let path = NMFPath()
        path.path = NMGLineString(points: points)
        path.color = UIColor.systemBlue
        path.width = 8
        path.mapView = mapView
        
        paths.append(path)
    }
    // 마커 추가
    func addMarker(mapx: String, mapy: String, title: String) -> NMGLatLng? {
        guard let x = tm128Double(from: mapx),
              let y = tm128Double(from: mapy) else { return nil}
        
        let lagLng = NMGLatLng(lat: y, lng: x)
        
        let mapMarker = NMFMarker(position: lagLng)
        mapMarker.captionText = stripHTML(title)
        mapMarker.mapView = mapView
        
        markers.append(mapMarker)
        
        return lagLng
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
        let mapMarker = NMFMarker(position: latLng)
        mapMarker.captionText = stripHTML(title)
        
        mapMarker.touchHandler = { [weak self] overlay -> Bool in
            guard let self = self, let tapped = overlay as? NMFMarker else { return false }
            
            tapped.zIndex = 1000
            
            self.performSegue(withIdentifier: "ShowBottomSheet", sender: self)
            return true
        }
        
        mapMarker.mapView = mapView
        marker = mapMarker
        markers.append(mapMarker)
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
        if segue.identifier == "ShowBottomSheet" {
            
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
            
            if let infoVC = segue.destination as? InfoViewController {
                infoVC.item = selectedItem
                infoVC.mapView = self
            }
        }
        else if segue.identifier == "ShowDirections" {
            if let destVC = segue.destination as? DirectionsViewController {
                destVC.mapView = self
            }
        }
    }
}

 // MARK: - CLLocationManagerDelegate 구현
extension MapViewController: CLLocationManagerDelegate {
    // MARK: 상태 변경시 작동하는 코드
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            case .restricted:
                showAlert()
            case .denied:
                showAlert()
            case .authorizedAlways:
                manager.startUpdatingLocation()
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
        
        DispatchQueue.main.async {
            self.locationOverlay.location = target
            
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
