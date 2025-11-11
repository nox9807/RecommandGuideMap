import UIKit
import NMapsMap  // 네이버 지도 SDK

class RouteDetailViewController: UIViewController {
    
    // MARK: - 지도 관련
    private var naverMapView: NMFNaverMapView!
    private var mapView: NMFMapView { naverMapView.mapView }
    
    // MARK: - 데이터
    var route: RouteSummary!  // 전달받은 루트 데이터 (더미 또는 실제)
    
    // MARK: - 바텀 시트 관련
    @IBOutlet weak var bottomSheet: UIView!
    @IBOutlet weak var bottomSheetHeight: NSLayoutConstraint!
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // route가 전달되지 않았다면 crash 방지
        guard route != nil else {
            print("⚠️ route is nil — 데이터 전달 실패")
            return
        }
        
        setupMap()
        setupRouteMap()
        setupCloseButton()
        setupPanGesture()
        setupSheetShadow()
    }
    
    // MARK: - 지도 기본 세팅
    private func setupMap() {
        naverMapView = NMFNaverMapView(frame: view.bounds)
        naverMapView.showLocationButton = true
        naverMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(naverMapView, at: 0) // 지도를 맨 뒤에 추가
    }
    
    // MARK: - 루트 표시
    private func setupRouteMap() {
        // 전체 좌표 배열 생성
        let coords = [route.origin] + route.waypoints + [route.destination]
        let nmgCoords = coords.map { NMGLatLng(lat: $0.lat, lng: $0.lng) }
        
        // 경로선(폴리라인)
        let path = NMGLineString(points: nmgCoords)
        let polyline = NMFPolylineOverlay(path as! NMGLineString<AnyObject>)
        polyline?.color = UIColor.systemBlue
        polyline?.mapView = mapView
        
        // 마커들 추가
        addMarker(for: route.origin, color: .red)
        for wp in route.waypoints {
            addMarker(for: wp, color: .blue)
        }
        addMarker(for: route.destination, color: .purple)
        
        // 카메라를 모든 핀에 맞게 조정
        let bounds = NMGLatLngBounds(latLngs: nmgCoords)
        let update = NMFCameraUpdate(fit: bounds, padding: 80)
        mapView.moveCamera(update)
    }
    
    // MARK: - 마커 추가
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
        closeButton.tintColor = .black
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.frame = CGRect(x: 20, y: 60, width: 34, height: 34)
        closeButton.layer.shadowOpacity = 0.2
        closeButton.layer.shadowRadius = 2
        view.addSubview(closeButton)
    }
    
    @objc private func closeTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - 제스처 (시트 드래그)
    private func setupPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        bottomSheet.addGestureRecognizer(pan)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        switch gesture.state {
            case .changed:
                if translation.y < 0 { // 위로 드래그 중
                    bottomSheet.transform = CGAffineTransform(translationX: 0, y: translation.y)
                }
            case .ended:
                UIView.animate(withDuration: 0.3) {
                    self.bottomSheet.transform = translation.y < -100
                    ? CGAffineTransform(translationX: 0, y: -300) // 위로 올리기
                    : .identity // 원위치
                }
            default: break
        }
    }
    
    // MARK: - 시트 그림자 효과
    private func setupSheetShadow() {
        bottomSheet.layer.shadowColor = UIColor.black.cgColor
        bottomSheet.layer.shadowOpacity = 0.15
        bottomSheet.layer.shadowRadius = 6
        bottomSheet.layer.shadowOffset = CGSize(width: 0, height: -2)
    }
}
