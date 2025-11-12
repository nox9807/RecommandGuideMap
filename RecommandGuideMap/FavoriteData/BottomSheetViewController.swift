// BottomSheetViewController.swift
import UIKit

final class BottomSheetViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var starButton: UIButton!
    
    // RouteDetail에서 넘겨줄 데이터 (원하면)
    var route: RouteSummary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        // 윗모서리 둥글게 & 그림자 — 간단 버전
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.15
        view.layer.shadowRadius = 6
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        
        // 넘겨받은 걸 보여주고 싶으면
        label?.text = route?.title
    }
}
