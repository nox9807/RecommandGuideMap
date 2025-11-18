//
//  ViewController.swift
//  RecommandGuideMap
//
//  Created by JaeYeongMAC on 11/5/25.
//

import UIKit
import MapKit
import NMapsMap

/// 메인 지도를 담당하는 뷰 컨트롤러.
///
/// - 네이버 지도를 초기화하고,
/// - 현재 위치를 따라다니는 카메라를 관리하고,
/// - 검색/즐겨찾기/길찾기에서 넘어온 좌표를 포커스하거나,
/// - 출발/도착 지점을 기반으로 마커와 경로를 그리는 역할을 한다.
class MapViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    /// 지도 위에 올려진 UI들을 스크롤하기 위한 스크롤 뷰.
    @IBOutlet weak var scrollView: UIScrollView!
    
    /// 장소 검색을 시작하는 서치 바.
    @IBOutlet weak var searchBar: UISearchBar!
    
    /// 길찾기 버튼 (segue로 DirectionsViewController를 띄우는 용도).
    @IBOutlet weak var directionButton: UIButton!
    
    /// 모달로 열렸을 때 뷰를 닫는 X 버튼.
    @IBOutlet weak var xmarkButton: UIButton!
    
    /// X 버튼 탭 시 현재 뷰 컨트롤러를 닫는다.
    @IBAction func xmarkButton(_ sender: Any) {
        dismiss(animated: true)
    }
    // MARK: - Location & State
    
    /// CoreLocation 매니저. 위치 권한/업데이트를 관리한다.
    let manager = CLLocationManager()
    
    /// 카메라가 현재 사용자 위치를 계속 따라갈지 여부.
    /// 사용자가 지도를 드래그하면 `false`로 바뀐다.
    var isFollowingUser: Bool = true
    /// 상세정보에서 들어온 경우 검색 바를 숨기기 위한 플래그.
    /// `true`이면 상단 검색 바와 길찾기버튼을 숨긴다.
    var isHiddenViews = false
    
    /// 검색/즐겨찾기/리스트에서 선택되어 지도에 포커스할 검색 결과 아이템.
    var selectedItem: SearchResponse.SearchItem?
    
    // MARK: - Naver Map
    
    /// 네이버 지도의 루트 뷰. 위치 버튼 등 기본 UI를 포함한다.
    private var naverMapView: NMFNaverMapView!
    
    /// 실제 지도를 표시하는 NMFMapView. 항상 `naverMapView.mapView`를 래핑해서 사용.
    private var mapView: NMFMapView { naverMapView.mapView }
    
    /// 단일 포커스용 마커
    private var marker: NMFMarker?
    
    /// 위치 오버레이(내 위치 점)를 컨트롤하는 객체.
    private var locationOverlay: NMFLocationOverlay!
    
    /// 지도 위에 표시된 모든 마커들을 관리하는 배열.
    private var markers: [NMFMarker] = []
    
    /// 지도 위에 표시된 모든 경로(NMFPath)를 관리하는 배열.
    private var paths: [NMFPath] = []
    
    /// 전체 마커/경로를 지우는 버튼 액션.
    @IBAction func vtn(_ sender: Any) {
        clearMap()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 테마 상세 화면에서 왔을 경우 상단 검색 바를 숨긴다.
        if isHiddenViews {
            searchBar.isHidden = true
            directionButton.isHidden = true
            xmarkButton.isHidden = false
        }
        
        // 위치 매니저 설정
        manager.distanceFilter = 5
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        
        // 네이버 맵 뷰 생성 및 현재 뷰에 추가
        naverMapView = NMFNaverMapView(frame: view.bounds)
        naverMapView.showLocationButton = true
        naverMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(naverMapView)
        view.sendSubviewToBack(naverMapView)
        
        mapView.positionMode = .normal
        
        // 내 위치 오버레이 표시
        locationOverlay = mapView.locationOverlay
        locationOverlay.hidden = false
        
        searchBar.backgroundImage = UIImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 다른 화면에서 아이템을 넘겨받은 경우 지도 포커스 + 정보 시트 표시
        if let item = selectedItem {
            focus(mapx: item.mapx, mapy: item.mapy, title: item.title)
            performSegue(withIdentifier: "ShowBottomSheet", sender: self)
        }
    }
    
    // MARK: - Search Presentation
    
    /// 검색 화면을 모달로 띄운 뒤,
    /// 사용자가 장소를 선택하면 그 좌표로 지도 포커스 + 정보 시트를 띄운다.
    func presentSearch() {
        let vc = storyboard?.instantiateViewController(identifier: "SearchViewController") as! SearchViewController
        vc.modalPresentationStyle = .overFullScreen
        
        // 검색 결과 중 하나를 선택했을 때 호출되는 클로저.
        vc.onSelect = { [weak self] item in
            guard let self = self else { return }
            
            // 선택한 아이템 저장
            self.selectedItem = item
            
            // 검색 화면을 닫은 후에 지도 포커스 + 바텀 시트 표시
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
    
    // MARK: - Route Focus & Drawing
    /// 출발지/도착지(또는 여러 지점)의 좌표를 받아서
    /// 카메라를 모든 지점이 보이도록 이동시키고, 마커 및 경로를 표시한다.
    ///
    ///   - `mapx`, `mapy`는 TM128 문자열 또는 위도/경도 문자열.
    func mapViewFocus(points: [(mapx: String, mapy: String, title: String)]) {
        
        clearMap()
        
        var latLngPoints: [NMGLatLng] = []
        
        // 각 포인트에 마커를 추가하고, 변환된 좌표를 배열에 저장
        for point in points {
            if let latLng = addMarker(mapx: point.mapx, mapy: point.mapy, title: point.title) {
                latLngPoints.append(latLng)
            }
        }
        
        // 최소 2개 지점이 있어야 경로/영역을 계산할 수 있다.
        guard latLngPoints.count >= 2 else { return }
        
        let lats = latLngPoints.map { $0.lat }
        let lngs = latLngPoints.map { $0.lng }
        
        // 위도/경도 최소·최대값으로 bounds 계산
        let bound = NMGLatLngBounds(
            southWest: NMGLatLng(lat: lats.min() ?? 0, lng: lngs.min() ?? 0),
            northEast: NMGLatLng(lat: lats.max() ?? 0, lng: lngs.max() ?? 0)
        )
        
        // 모든 지점이 화면에 들어오도록 카메라 이동
        let cameraUpdate = NMFCameraUpdate(fit: bound, padding: 100)
        cameraUpdate.animation = .easeIn
        mapView.moveCamera(cameraUpdate)
        
        drawPath(points: latLngPoints)
    }
    /// 위도/경도 배열을 받아서 지도 위에 경로(Path)를 그린다.
    ///
    func drawPath(points: [NMGLatLng]) {
        guard points.count >= 2 else { return }
        let path = NMFPath()
        path.path = NMGLineString(points: points)
        path.color = UIColor.systemBlue
        path.width = 8
        path.mapView = mapView
        
        paths.append(path)
    }
    
    /// TM128 문자열(or double 형식 문자열)을 위도/경도로 변환하고
    /// 지도에 마커를 추가한 뒤, 변환된 좌표를 반환한다.
    ///
    /// - Parameters:
    ///   - mapx: TM128 기준 x 좌표 문자열 또는 "경도" 문자열.
    ///   - mapy: TM128 기준 y 좌표 문자열 또는 "위도" 문자열.
    ///   - title: 마커에 표시할 장소 이름.
    /// - Returns: 마커가 위치한 `NMGLatLng`. 변환 실패 시 `nil`.
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
    
    // MARK: - Single Focus & Marker (검색 결과 등)
    
    /// 단일 좌표에 카메라를 이동시키고, 해당 위치에 마커를 표시한다.
    ///
    /// - Parameters:
    ///   - mapx: TM128 또는 위도/경도 문자열 (x 또는 경도).
    ///   - mapy: TM128 또는 위도/경도 문자열 (y 또는 위도).
    ///   - title: 마커에 표시할 장소 제목.
    func focus(mapx: String, mapy: String, title: String) {
        guard let x = tm128Double(from: mapx),
              let y = tm128Double(from: mapy) else { return }
        
        clearMap()
        
        isFollowingUser = false
        
        let latLng = NMGLatLng(lat: y, lng: x)
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: latLng)
        cameraUpdate.animation = .easeIn
        mapView.moveCamera(cameraUpdate)
        
        // 기존 단일 마커 제거 후 새 마커 추가
        marker?.mapView = nil
        
        let mapMarker = NMFMarker(position: latLng)
        mapMarker.captionText = stripHTML(title)
        
        // 마커 탭했을 때 상세 정보 시트를 띄우기 위한 핸들러
        mapMarker.touchHandler = { [weak self] overlay -> Bool in
            guard let self = self, let tapped = overlay as? NMFMarker else { return false }
            
            // 선택된 마커를 위로 올리기 위해 zIndex 조정
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
    
    // MARK: - Bottom Sheet / Segue
    
    /// 바텀 시트(InfoViewController)와 길찾기 화면(DirectionsViewController)을 띄우기 위한 세그 준비 메소드.
    ///
    /// - "ShowBottomSheet": 장소 상세/즐겨찾기/길찾기 버튼이 있는 하단 시트
    /// - "ShowDirections": 출발/도착지를 입력하는 길찾기 화면
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

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    /// 위치 권한 상태가 바뀔 때마다 호출된다.
    /// 권한에 따라 위치 업데이트 시작/중단 및 알림 표시를 수행한다.
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
                manager.startUpdatingLocation()
            @unknown default:
                break
        }
    }
    
    /// 위치가 업데이트될 때마다 호출된다.
    /// - 내 위치 오버레이를 갱신하고,
    /// - `isFollowingUser == true`면 카메라도 함께 이동시킨다.
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
    
    /// 위치 업데이트 중 에러가 발생했을 때 호출된다.
    /// - 중요한 에러만 로그를 출력하고, 위치 업데이트를 중단한다.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        // 자잘한 에러는 무시
        let error = error as NSError
        // 자잘한 에러는 무시
        guard error.code != CLError.Code.locationUnknown.rawValue else { return }
        
        print(error)
        manager.stopUpdatingLocation()
    }
}

// MARK: - UISearchBarDelegate

extension MapViewController: UISearchBarDelegate {
    // editing을 false로 만들고 서치바를 누르면 서치페이지가 모달되게함
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        presentSearch()
        return false
    }
}

// MARK: - NMFMapViewCameraDelegate

extension MapViewController: NMFMapViewCameraDelegate {
    /// 카메라 이동 원인에 따라 `isFollowingUser` 플래그를 조정한다.
    /// - 제스처로 움직이면 사용자 조작으로 판단하여 위치 추적을 끈다.
    /// - 버튼 등 컨트롤로 이동하면 위치 추적을 다시 켠다.
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
