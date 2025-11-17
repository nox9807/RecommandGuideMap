// FavoriteStore.swift

import Foundation

struct FavoritePlace {
    let id: String
    let name: String
    let address: String
    let categoryOrDistance: String
    let lat: Double
    let lng: Double
}


final class FavoriteStore {
    static let shared = FavoriteStore()
    private init() {}
    
    private(set) var places: [FavoritePlace] = []
    
    func add(from location: Location) {
        let place = FavoritePlace(
            id: location.id,
            name: location.name,
            address: location.address,
            categoryOrDistance: location.distanceText, // "카페 · 0.5km" 같은 느낌
            lat: location.lat,
            lng: location.lng
        )
        
        // 이미 같은 장소가 있으면 또 추가하지 않기 (선택사항)
        if places.contains(where: { $0.id == place.id }) {
            return
        }
        
        places.append(place)
    }
}
