//
//  ViewController.swift
//  RecommandGuideMap
//
//  Created by JaeYeongMAC on 11/5/25.
//

import UIKit

import NMapsMap

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mapView = NMFMapView(frame: view.frame)
        view.addSubview(mapView)
        
    }
}

