//
//  FavoriteModalViewController 2.swift
//  RecommandGuideMap
//
//  Created by chaeyoonpark on 11/7/25.
//


import UIKit

class FavoriteModalViewController: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!

    private var currentChild: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // 기본 탭은 장소
        showChild(named: "PlaceViewController")
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            showChild(named: "PlaceViewController")
        } else {
            showChild(named: "RouteViewController")
        }
    }

    private func showChild(named name: String) {
        // 기존 자식 제거
        currentChild?.willMove(toParent: nil)
        currentChild?.view.removeFromSuperview()
        currentChild?.removeFromParent()

        // 새 자식 불러오기
        let storyboard = UIStoryboard(name: "Favorite", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: name) as? UIViewController else { return }

        addChild(vc)
        vc.view.frame = containerView.bounds
        containerView.addSubview(vc.view)
        vc.didMove(toParent: self)
        currentChild = vc
    }
    
    
}
