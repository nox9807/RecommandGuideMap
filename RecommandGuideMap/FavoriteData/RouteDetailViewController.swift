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
    
    // MARK: - 바텀 시트
    @IBOutlet weak var bottomSheet: UIView!
    @IBOutlet weak var bottomSheetHeight: NSLayoutConstraint!
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  지도/현재위치는 항상 세팅
        setupMap()
        setupLocation()
        setupCloseButton()
        setupPanGesture()
        setupSheetShadow()
        
        //  route가 있으면 경로만 그리기
        if let route = route {
            setupRouteMap(with: route)
        } else {
            print("⚠️ route is nil — 데이터 전달 실패(지도는 정상 초기화됨)")
        }
        
        // 지도 뒤, 시트 앞으로
        view.bringSubviewToFront(bottomSheet)
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
    
    // MARK: - 바텀시트 드래그
    private func setupPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        bottomSheet.addGestureRecognizer(pan)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let t = gesture.translation(in: view)
        switch gesture.state {
            case .changed:
                if t.y < 0 { bottomSheet.transform = CGAffineTransform(translationX: 0, y: t.y) }
            case .ended:
                UIView.animate(withDuration: 0.3) {
                    self.bottomSheet.transform = t.y < -100
                    ? CGAffineTransform(translationX: 0, y: -300)
                    : .identity
                }
            default: break
        }
    }
    
    // MARK: - 시트 그림자
    private func setupSheetShadow() {
        bottomSheet.layer.shadowColor = UIColor.black.cgColor
        bottomSheet.layer.shadowOpacity = 0.15
        bottomSheet.layer.shadowRadius = 6
        bottomSheet.layer.shadowOffset = CGSize(width: 0, height: -2)
    }
}
