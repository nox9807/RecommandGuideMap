import UIKit
import NMapsMap
import CoreLocation

final class FavoriteMapViewController: BaseMapViewController {
    
    private var bottomSheetVC: FavoriteModalViewController?
    private var bottomSheetView: UIView!
    private var panGesture = UIPanGestureRecognizer()
    
    // collapsed 상태에서 보일 높이(헤더 영역)
    private let collapsedHeight: CGFloat = 270
    
    // 바텀시트 전체 높이 = 화면 전체
    private var sheetFullHeight: CGFloat {
        view.bounds.height
    }
    
    // 완전히 올렸을 때 Y = 탭바 위까지 딱 맞게
    private var expandedTopY: CGFloat {
        return safeAreaTop
    }
    
    // 접혔을 때 Y
    private var collapsedTopY: CGFloat {
        return view.bounds.height - collapsedHeight - tabBarHeight
    }
    
    private var safeAreaTop: CGFloat {
        return view.safeAreaInsets.top
    }
    
    private var tabBarHeight: CGFloat {
        return tabBarController?.tabBar.frame.height ?? 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if bottomSheetVC == nil {
            attachBottomSheet()
        }
    }
    
    // MARK: 바텀시트 생성
    private func attachBottomSheet() {
        
        let storyboard = UIStoryboard(name: "Favorite", bundle: nil)
        guard let modalVC = storyboard.instantiateViewController(
            withIdentifier: "FavoriteModalViewController"
        ) as? FavoriteModalViewController else {
            print("FavoriteModalViewController 못 찾음")
            return
        }
        
        bottomSheetVC = modalVC
        addChild(modalVC)
        
        let sheetView = modalVC.view!
        bottomSheetView = sheetView
        
        // ★ 전체 높이로 잡기 (iOS pageSheet처럼)
        sheetView.frame = CGRect(
            x: 0,
            y: collapsedTopY,
            width: view.bounds.width,
            height: sheetFullHeight
        )
        
        sheetView.layer.cornerRadius = 20
        sheetView.clipsToBounds = true
        applyMaskTo(sheetView)
        addGrabber(to: sheetView)
        
        view.addSubview(sheetView)
        modalVC.didMove(toParent: self)
        
        // 드래그 제스처 추가
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        sheetView.addGestureRecognizer(panGesture)
    }
    
    // MARK: 드래그
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let sheetView = bottomSheetView else { return }
        
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
            case .changed:
                var newY = sheetView.frame.origin.y + translation.y
                
                // 위로 끝까지 = safeAreaTop
                newY = max(expandedTopY, newY)
                
                // 아래로 = collapsedTopY
                newY = min(collapsedTopY, newY)
                
                sheetView.frame.origin.y = newY
                gesture.setTranslation(.zero, in: view)
                
            case .ended, .cancelled:
                let midY = (expandedTopY + collapsedTopY) / 2
                let currentY = sheetView.frame.origin.y
                let targetY: CGFloat
                
                if velocity.y < -500 {
                    targetY = expandedTopY
                } else if velocity.y > 500 {
                    targetY = collapsedTopY
                } else {
                    targetY = (currentY < midY) ? expandedTopY : collapsedTopY
                }
                
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
                    sheetView.frame.origin.y = targetY
                }
                
            default:
                break
        }
    }
    
    // MARK: 둥근 모서리 유지
    private func applyMaskTo(_ view: UIView) {
        let path = UIBezierPath(
            roundedRect: view.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: 20, height: 20)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        view.layer.mask = mask
    }
    
    // MARK: Grabber
    private func addGrabber(to sheet: UIView) {
        let grabber = UIView(frame: CGRect(x: 0, y: 8, width: 40, height: 6))
        grabber.backgroundColor = UIColor.systemGray3
        grabber.layer.cornerRadius = 3
        grabber.center.x = sheet.center.x
        grabber.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        sheet.addSubview(grabber)
    }
}
