//
//  TouchScrollView.swift
//  RecommandGuideMap
//
//  Created by JaeYeongMAC on 11/10/25.
//

import Foundation
import UIKit

final class TouchScrollView: UIScrollView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        delaysContentTouches = false
        canCancelContentTouches = true
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl { return true }
        return super.touchesShouldCancel(in: view)
    }
}
