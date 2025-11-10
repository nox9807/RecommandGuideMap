//
//  PlaceMapViewController.swift
//  RecommandGuideMap
//
//  Created by 이찬희 on 11/10/25.
//

import UIKit
import NMapsMap

final class PlaceMapViewController: UIViewController {
    var place: Place!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mapView = NMFMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        
        let pos = NMGLatLng(lat: place.lat, lng: place.lng)
        mapView.moveCamera(NMFCameraUpdate(scrollTo: pos, zoomTo: 16))
        
        let marker = NMFMarker(position: pos)
        marker.captionText = place.name
        marker.mapView = mapView
    }
}
