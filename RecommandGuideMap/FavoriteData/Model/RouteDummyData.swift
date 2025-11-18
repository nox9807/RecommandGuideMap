import Foundation
import CoreLocation

// MARK: - 개별 장소
struct RoutePlace {
    let name: String
    let lat: Double
    let lng: Double
}

// MARK: - 전체 루트 요약 (지도 + 텍스트용 통합)
struct RouteSummary {
    let title: String              // 루트 이름
    let origin: RoutePlace         // 출발지
    let waypoints: [RoutePlace]    // 경유지
    let destination: RoutePlace    // 도착지
    let categoryCounts: [String:Int] // 관광명소, 식당, 숙박 등 개수
    
    // 카테고리 요약 문구 (예: "관광명소 3개 · 식당 2개")
    var summaryText: String {
        categoryCounts
            .filter { $0.value > 0 }
            .sorted { $0.key < $1.key }
            .map { "\($0.key) \($0.value)개" }
            .joined(separator: " · ")
    }
}
