import Foundation
import UIKit     
import CoreData

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
    private init() {
        self.context = (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer
            .viewContext
        
        fetchFavorites()   // 앱 실행 시 CoreData에서 불러오기
    }
    
    private let context: NSManagedObjectContext
    private(set) var places: [FavoritePlace] = []
}

// MARK: - Public API
extension FavoriteStore {
    
    // ⭐ 저장 (Theme Location 기반)
    func add(from location: Location) {
        let entity = FavoritePlaceEntity(context: context)
        
        entity.id = location.id
        entity.name = location.name
        entity.address = location.address
        entity.categoryOrDistance = location.distanceText
        entity.lat = location.lat
        entity.lng = location.lng
        
        saveContext()
        fetchFavorites()
    }
    
    // ⭐ 저장 (Map Search 기반)
    func add(from item: SearchResponse.SearchItem) {
        
        let lat = Double(item.mapy) ?? 0
        let lng = Double(item.mapx) ?? 0
        let uniqueID = "\(item.title)_\(item.mapx)_\(item.mapy)"
        
        let entity = FavoritePlaceEntity(context: context)
        
        entity.id = uniqueID
        entity.name = stripHTML(item.title)
        entity.address = item.roadAddress.isEmpty ? item.address : item.roadAddress
        entity.categoryOrDistance = item.category
        entity.lat = lat
        entity.lng = lng
        
        saveContext()
        fetchFavorites()
    }
    
    // ⭐ 삭제
    func delete(id: String) {
        let request: NSFetchRequest<FavoritePlaceEntity> = FavoritePlaceEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        
        if let result = try? context.fetch(request).first {
            context.delete(result)
            saveContext()
            fetchFavorites()
        }
    }
}

// MARK: - Core Data
private extension FavoriteStore {
    
    func fetchFavorites() {
        let request: NSFetchRequest<FavoritePlaceEntity> = FavoritePlaceEntity.fetchRequest()
        
        guard let results = try? context.fetch(request) else { return }
        
        self.places = results.map {
            FavoritePlace(
                id: $0.id ?? "",
                name: $0.name ?? "",
                address: $0.address ?? "",
                categoryOrDistance: $0.categoryOrDistance ?? "",
                lat: $0.lat,
                lng: $0.lng
            )
        }
    }
    
    func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }
}
