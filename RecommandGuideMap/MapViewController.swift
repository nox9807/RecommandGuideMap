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
    
    let manager = CLLocationManager()
    
    // 기존 mapView만으로 지도를 구현했는데 showLoactionButton이 NMFNaverMapView에서만 제공되는 API라 NMFNaverMapView를 루트로 쓰고 내부의 실제 지도는 mapView: NMFMapView로 읽기 전용 계싼 프로퍼티로 기존코드를 그대로 사용
    private var naverMapView: NMFNaverMapView!
    private var mapView: NMFMapView { naverMapView.mapView }
    
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
        
        locationOverlay = mapView.locationOverlay
        locationOverlay.hidden = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: -알림 표시(위치 서비스를 비활성화 했을 때)
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
    
    // MARK: location이 업데이트 될때마다 위치 변경
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last else { return }
        let coord = last.coordinate
        let target = NMGLatLng(lat: coord.latitude, lng: coord.longitude)
        
        DispatchQueue.main.async {
            self.locationOverlay.location = target
            print(self.locationOverlay.location)
            
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
