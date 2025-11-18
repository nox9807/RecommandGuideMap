import UIKit

final class FavoriteModalViewController: UIViewController {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    private var currentChild: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showChild(named: "PlaceViewController")
    }
    
    // MARK: - UI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        
        // 윗 모서리만 둥글게 (UIBezierPath)
        let path = UIBezierPath(
            roundedRect: view.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: 20, height: 20)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        view.layer.mask = mask
        
        // Grabber 추가
        let grabber = UIView(frame: CGRect(x: (view.bounds.width - 40)/2, y: 8, width: 40, height: 5))
        grabber.layer.cornerRadius = 2.5
        grabber.backgroundColor = .systemGray3
        grabber.clipsToBounds = true
        view.addSubview(grabber)
    }

    
    
    // MARK: - 세그먼트 변경
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            showChild(named: "PlaceViewController")
        } else {
            showChild(named: "RouteViewController")
        }
    }
    
    
    // MARK: - 자식 컨트롤러 전환
    private func showChild(named name: String) {
        currentChild?.willMove(toParent: nil)
        currentChild?.view.removeFromSuperview()
        currentChild?.removeFromParent()
        
        let storyboard = UIStoryboard(name: "Favorite", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: name)
        
        addChild(vc)
        vc.view.frame = containerView.bounds
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(vc.view)
        vc.didMove(toParent: self)
        currentChild = vc
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyCornerMask()
    }
    
    private func applyCornerMask() {
        let path = UIBezierPath(
            roundedRect: view.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: 20, height: 20)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        view.layer.mask = mask
    }
}
