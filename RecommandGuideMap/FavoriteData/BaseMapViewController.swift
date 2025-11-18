import UIKit
import NMapsMap
import CoreLocation

///  공통 지도 뷰컨트롤러 (상속해서 사용)
class BaseMapViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - 지도 관련
    var naverMapView: NMFNaverMapView!
    var mapView: NMFMapView { naverMapView.mapView }
    let locationManager = CLLocationManager()
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        setupLocation()
    }
    
    // MARK: - 지도 기본 세팅
    func setupMap() {
        naverMapView = NMFNaverMapView(frame: view.bounds)
        naverMapView.showLocationButton = true
        naverMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(naverMapView, at: 0)
        
        mapView.positionMode = .normal
        mapView.locationOverlay.hidden = false
    }
    
    // MARK: - 현재 위치
    func setupLocation() {
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
    
    // MARK: - 마커 추가
    func addMarker(for place: RoutePlace, color: UIColor) {
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: place.lat, lng: place.lng)
        marker.captionText = place.name
        marker.iconTintColor = color
        marker.mapView = mapView
    }
    
    // MARK: - 루트 경로 표시
    func drawRoute(_ route: RouteSummary) {
        let coords = [route.origin] + route.waypoints + [route.destination]
        let nmgCoords = coords.map { NMGLatLng(lat: $0.lat, lng: $0.lng) }
        
        let path = NMGLineString(points: nmgCoords) as! NMGLineString<AnyObject>
        let polyline = NMFPolylineOverlay(path)
        polyline?.color = UIColor.systemBlue
        polyline?.mapView = mapView
        
        addMarker(for: route.origin, color: .red)
        route.waypoints.forEach { addMarker(for: $0, color: .blue) }
        addMarker(for: route.destination, color: .purple)
        
        let bounds = NMGLatLngBounds(latLngs: nmgCoords)
        let update = NMFCameraUpdate(fit: bounds, padding: 80)
        mapView.moveCamera(update)
    }
}

