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
        dismiss(animated: true)
        // 혹시 네비게이션 push 방식이면 아래로 바꿔야 함
        // navigationController?.popViewController(animated: true)
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
        
        sheetVC.route = route           // 선택한 루트 데이터 전달
        sheetVC.modalPresentationStyle = .pageSheet
        
        if let sheet = sheetVC.sheetPresentationController {
            sheetVC.isModalInPresentation = true      // 아래로 당겨도 dismiss 안 되게
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 30
            
            // ① 아래로 내렸을 때: 제목 + 별 버튼만 보이는 높이
            let headerDetent = UISheetPresentationController.Detent.custom(
                identifier: .init("header")
            ) { _ in
                return 80   // 필요하면 110~140 사이로 조절
            }
            
            // ② 처음 올라올 때: 콘텐츠 전체(출발/경유/도착) 보이는 높이
            let contentDetent = UISheetPresentationController.Detent.custom(
                identifier: .init("content")
            ) { _ in
                // 방금 BottomSheetViewController에서 계산해 둔 높이 사용
                return sheetVC.preferredContentSize.height
            }
            
            // 두 단계 설정
            sheet.detents = [headerDetent, contentDetent]
            
            // ▶ 처음에는 “내용 전체” 높이로 띄우기
            sheet.selectedDetentIdentifier = contentDetent.identifier
            
            // dim(배경 어두워지는 범위)은 그냥 전체로 두고 싶으면 nil 또는 contentDetent
            sheet.largestUndimmedDetentIdentifier = contentDetent.identifier
        }
        
        present(sheetVC, animated: true)
    }
}
