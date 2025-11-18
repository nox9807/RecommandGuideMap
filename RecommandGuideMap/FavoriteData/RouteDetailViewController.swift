import UIKit
import NMapsMap
import CoreLocation

final class RouteDetailViewController: BaseMapViewController {
    
    // MARK: - 데이터
    var route: RouteSummary?
    
    // 이미 시트를 띄웠는지 여부
    private var didPresentSheet = false
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCloseButton()
        
        if let route = route {
            drawRoute(route)   // BaseMapViewController 메서드 재사용
            print("RouteDetailViewController.route.title =", route.title)
        } else {
            print("route 데이터가 없습니다.")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 여러 번 호출되는 거 방지
        if didPresentSheet == false {
            didPresentSheet = true
            presentBottomSheet()
        }
    }
    
    // MARK: - 닫기 버튼
    private func setupCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.frame = CGRect(x: view.bounds.width - 70, y: 60, width: 40, height: 40)
        closeButton.layer.shadowOpacity = 0.2
        closeButton.layer.shadowRadius = 2
        view.addSubview(closeButton)
    }
    
    @objc private func closeTapped() {
        view.window?.rootViewController?.dismiss(animated: true)
    }
    
    // MARK: - 바텀시트 표시
    private func presentBottomSheet() {
        let storyboard = UIStoryboard(name: "Favorite", bundle: nil)
        guard let sheetVC = storyboard.instantiateViewController(
            withIdentifier: "BottomSheetViewController"
        ) as? BottomSheetViewController else {
            print("BottomSheetViewController를 Favorite.storyboard에서 찾지 못했습니다.")
            return
        }
        
        sheetVC.route = route
        sheetVC.modalPresentationStyle = .pageSheet
        
        present(sheetVC, animated: true) { [weak self, weak sheetVC] in
            guard
                let self,
                let sheetVC,
                let sheet = sheetVC.sheetPresentationController
            else { return }
            
            // MARK: - 1) 데이터 개수 계산
            // route.origin + waypoints + route.destination
            let waypointCount = sheetVC.route?.waypoints.count ?? 0
            let totalPlaces = waypointCount + 2    // origin + destination
            
            // MARK: - 2) UI 컴포넌트 높이 설정
            let headerHeight: CGFloat = 80
            let cellHeight: CGFloat = 90
            let bottomPadding: CGFloat = 20
            let visibleCells = min(totalPlaces, 3) // 최대 3개만 한 화면에서 전체 노출
            
            // MARK: - 3) 컨텐츠가 차지해야 할 목표 높이
            var contentHeight = headerHeight + (cellHeight * CGFloat(visibleCells)) + bottomPadding
            
            // MARK: - 4) 화면 최대 높이 제한 (85%)
            let screenHeight = self.view.window?.windowScene?.screen.bounds.height ?? 0
            let maxAllowedHeight = screenHeight * 0.85
            contentHeight = min(contentHeight, maxAllowedHeight)
            
            // MARK: - 5) collapsed 상태 (무조건 일정 높이)
            let collapsed = UISheetPresentationController.Detent.custom(
                identifier: .init("collapsed")
            ) { _ in 80 }
            
            // MARK: - 6) expanded 상태 (계산한 높이)
            let expanded = UISheetPresentationController.Detent.custom(
                identifier: .init("expanded")
            ) { _ in contentHeight }
            
            // MARK: - 7) Detents 적용
            sheet.detents = [collapsed, expanded]
            sheet.selectedDetentIdentifier = expanded.identifier
            sheet.largestUndimmedDetentIdentifier = expanded.identifier
            
            // MARK: - 8) 옵션
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 30
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
        }
    }
}
