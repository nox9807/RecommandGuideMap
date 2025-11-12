//
//  InfoViewController.swift
//  RecommandGuideMap
//
//  Created by JaeYeongMAC on 11/11/25.
//

import UIKit

class InfoViewController: UIViewController {
    
    var item: SearchResponse.SearchItem?
    
    @IBOutlet weak var placeTextLabel: UILabel!
    @IBOutlet weak var addressTextLabel: UILabel!
    
    @IBAction func startButton(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIUpdate()
    }
    
    // MARK: 텍스트 업데이트 메소드
    func UIUpdate() {
        guard let item else { return }
        placeTextLabel.text = item.title.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        addressTextLabel.text = item.roadAddress.isEmpty ? item.address : item.roadAddress
    }
}
