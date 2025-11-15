// FavoriteStore.swift

import Foundation

struct FavoritePlace {
    let name: String
    let address: String
    let category: String
    let mapx: String
    let mapy: String
}

final class FavoriteStore {
    static let shared = FavoriteStore()
    private init() {}
    
    private(set) var places: [FavoritePlace] = []
    
    func add(from item: SearchResponse.SearchItem) {
        let place = FavoritePlace(
            name: stripHTML(item.title),
            address: item.roadAddress.isEmpty ? item.address : item.roadAddress,
            category: item.category,    // 필요 없으면 다른 텍스트로 대체
            mapx: item.mapx,
            mapy: item.mapy
        )
        places.append(place)
    }
}
