import UIKit

final class BottomSheetViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var placeStackView: UIStackView!
    
    var route: RouteSummary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        
        // 없는 경우만 기본값 채우기 (updateUI 호출 X)
        if route == nil {
            route = RouteDummyData.samples.first
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()        // 단 1번
    }
    
    private func updateUI() {
        guard let route = route else { return }
        
        // 제목
        label.text = route.title
        
        // 기존 행 제거 — arrangedSubviews도 정확히 삭제
        for view in placeStackView.arrangedSubviews {
            placeStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        // 출발지
        placeStackView.addArrangedSubview(
            makeRow(icon: "mappin.and.ellipse", text: route.origin.name)
        )
        
        // 경유지
        for place in route.waypoints {
            placeStackView.addArrangedSubview(
                makeRow(icon: "mappin", text: place.name)
            )
        }
        
        // 도착지
        placeStackView.addArrangedSubview(
            makeRow(icon: "flag.checkered", text: route.destination.name)
        )
    }
    
    private func makeRow(icon: String, text: String) -> UIView {
        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.spacing = 12
        hStack.alignment = .center
        
        let img = UIImageView(image: UIImage(systemName: icon))
        img.tintColor = .color
        img.widthAnchor.constraint(equalToConstant: 30).isActive = true
        img.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 18)
        
        hStack.addArrangedSubview(img)
        hStack.addArrangedSubview(label)
        
        return hStack
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 오토레이아웃 다 계산된 뒤 기준으로 높이 측정
        view.layoutIfNeeded()
        
        // placeStackView의 맨 아래(Y) + 아래 여백(마음대로 조절)
        let contentBottom = placeStackView.frame.maxY
        let bottomPadding: CGFloat = 20
        
        let totalHeight = contentBottom + bottomPadding
        
        // 시트가 “내용만큼” 올라올 때 쓸 기준 높이
        preferredContentSize = CGSize(width: view.bounds.width,
                                      height: totalHeight)
    }
}

