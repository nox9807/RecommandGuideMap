import Foundation
import CoreLocation

struct RouteRouteDetailPlaceFavorite {
    var title: String
    var origin: RoutePlace
    var waypoints: [RoutePlace]
    var destination: RoutePlace
    var polyline: [CLLocationCoordinate2D]
}

struct RouteDetailPlace {
    var name: String
    var address: String
    var lat: Double
    var lng: Double
    var thumbnailName: String?
}


