//
//  PlaceMapViewController.swift
//  RecommandGuideMap
//
//  Created by 이찬희 on 11/10/25.
//

import UIKit
import NMapsMap

final class LocationMapViewController: UIViewController {
    var location: Location!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mapView = NMFMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        
        let pos = NMGLatLng(lat: location.lat, lng: location.lng)
        mapView.moveCamera(NMFCameraUpdate(scrollTo: pos, zoomTo: 16))
        
        let marker = NMFMarker(position: pos)
        marker.captionText = location.name
        marker.mapView = mapView
    }
}
