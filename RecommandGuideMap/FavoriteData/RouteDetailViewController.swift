import UIKit
import NMapsMap
import CoreLocation

class RouteDetailViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - 지도 관련
    private var naverMapView: NMFNaverMapView!
    private var mapView: NMFMapView { naverMapView.mapView }
    private let locationManager = CLLocationManager()
    
    // MARK: - 데이터
    var route: RouteSummary?   // <- 옵셔널로
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  지도/현재위치는 항상 세팅
        setupMap()
        setupLocation()
        setupCloseButton()
        
        //  route가 있으면 경로만 그리기
        if let route = route {
            setupRouteMap(with: route)
        } else {
            print("⚠️ route is nil — 데이터 전달 실패(지도는 정상 초기화됨)")
        }
    }
    
    // MARK: - 지도 기본 세팅
    private func setupMap() {
        naverMapView = NMFNaverMapView(frame: view.bounds)
        naverMapView.showLocationButton = true
        naverMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(naverMapView, at: 0)
        
        mapView.positionMode = .normal
        mapView.locationOverlay.hidden = false
    }
    
    // MARK: - 현재 위치(권한 요청은 첫 화면에서 이미 수행)
    private func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - 위치 업데이트
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coord = locations.last?.coordinate else { return }
        let target = NMGLatLng(lat: coord.latitude, lng: coord.longitude)
        
        mapView.locationOverlay.location = target
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: target)
        cameraUpdate.animation = .easeIn
        mapView.moveCamera(cameraUpdate)
    }
    
    // MARK: - 루트 표시
    private func setupRouteMap(with route: RouteSummary) {
        let coords = [route.origin] + route.waypoints + [route.destination]
        let nmgCoords = coords.map { NMGLatLng(lat: $0.lat, lng: $0.lng) }
        
        //  폴리라인 생성 (SDK 제네릭 대응 버전)
        let path = NMGLineString(points: nmgCoords) as! NMGLineString<AnyObject>
        let polyline = NMFPolylineOverlay(path)
        polyline?.color = UIColor.systemBlue
        polyline?.mapView = mapView
        
        //  마커 추가
        addMarker(for: route.origin, color: .red)
        route.waypoints.forEach { addMarker(for: $0, color: .blue) }
        addMarker(for: route.destination, color: .purple)
        
        //  카메라 이동
        let bounds = NMGLatLngBounds(latLngs: nmgCoords)
        let update = NMFCameraUpdate(fit: bounds, padding: 80)
        mapView.moveCamera(update)
    }


    
    private func addMarker(for place: RoutePlace, color: UIColor) {
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: place.lat, lng: place.lng)
        marker.captionText = place.name
        marker.iconTintColor = color
        marker.mapView = mapView
    }
    
    // MARK: - 닫기 버튼
    private func setupCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.frame = CGRect(x: 330, y: 60, width: 100, height: 100)
        closeButton.layer.shadowOpacity = 0.2
        closeButton.layer.shadowRadius = 2
        view.addSubview(closeButton)
    }
    
    @objc private func closeTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func presentBottomSheet() {
        let sb = UIStoryboard(name: "Favorite", bundle: nil) // ✅ 수정: "Main" → "Favorite"
        guard let sheetVC = sb.instantiateViewController(
            withIdentifier: "BottomSheetVC"
        ) as? BottomSheetViewController else {
            assertionFailure("❌ BottomSheetVC를 Favorite.storyboard에서 찾지 못했습니다.")
            return
        }
        
        sheetVC.route = route
        sheetVC.modalPresentationStyle = .pageSheet
        
        if #available(iOS 15.0, *) {
            if let sheet = sheetVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.selectedDetentIdentifier = .medium
                sheet.largestUndimmedDetentIdentifier = .medium
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 16
            }
        }
        
        present(sheetVC, animated: true)
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentBottomSheet()
    }

}
