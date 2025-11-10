import Foundation
import CoreLocation

struct RouteFavorite {
    var title: String
    var origin: RoutePlace
    var waypoints: [RoutePlace]
    var destination: RoutePlace
    var polyline: [CLLocationCoordinate2D]
}

struct RoutePlace {
    var name: String
    var address: String
    var lat: Double
    var lng: Double
    var thumbnailName: String?
}
