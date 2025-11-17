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
    
    // ⭐ ThemeDetailViewController → Location 기반 즐겨찾기
    func add(from location: Location) {
        let place = FavoritePlace(
            id: location.id,
            name: location.name,
            address: location.address,
            categoryOrDistance: location.distanceText,
            lat: location.lat,
            lng: location.lng
        )
        
        if places.contains(where: { $0.id == place.id }) { return }
        places.append(place)
    }
    
    // ⭐ 지도 검색 화면 → SearchItem 기반 즐겨찾기
    func add(from searchItem: SearchResponse.SearchItem) {
        
        // mapx, mapy → Double 변환
        let lat = Double(searchItem.mapy) ?? 0
        let lng = Double(searchItem.mapx) ?? 0
        let uniqueID = "\(searchItem.title)_\(searchItem.mapx)_\(searchItem.mapy)"
        
        let place = FavoritePlace(
            id: uniqueID,    // SearchItem에는 고유 id 없음 → link로 대체
            name: stripHTML(searchItem.title),
            address: searchItem.roadAddress.isEmpty ? searchItem.address : searchItem.roadAddress,
            categoryOrDistance: searchItem.category,
            lat: lat,
            lng: lng
        )
        
        if places.contains(where: { $0.id == place.id }) { return }
        places.append(place)
    }
}
