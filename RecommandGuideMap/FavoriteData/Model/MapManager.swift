import UIKit
import NMapsMap
import CoreLocation

final class MapManager: NSObject {
    
    static let shared = MapManager()
    
    private let locationManager = CLLocationManager()
    private var locationOverlay: NMFLocationOverlay?
    private var mapView: NMFMapView?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /// 지도 세팅 (UIView 위에 지도 깔기)
    func setupMap(in container: UIView) -> NMFNaverMapView {
        let naverMapView = NMFNaverMapView(frame: container.bounds)
        naverMapView.showLocationButton = true
        naverMapView.showZoomControls = false
        naverMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.addSubview(naverMapView)
        
        self.mapView = naverMapView.mapView
        self.mapView?.positionMode = .direction
        self.locationOverlay = naverMapView.mapView.locationOverlay
        self.locationOverlay?.hidden = false
        
        locationManager.requestWhenInUseAuthorization()
        return naverMapView
    }
}

extension MapManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
            case .denied, .restricted:
                print("위치 권한 거부됨")
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            @unknown default:
                break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        let coord = NMGLatLng(lat: loc.coordinate.latitude, lng: loc.coordinate.longitude)
        
        // 파란 점 표시 + 카메라 이동
        locationOverlay?.location = coord
        
        if let mapView = mapView {
            let update = NMFCameraUpdate(scrollTo: coord)
            update.animation = .easeIn
            mapView.moveCamera(update)
        }
    }
}
