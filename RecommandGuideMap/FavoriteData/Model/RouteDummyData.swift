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

// MARK: - 더미 데이터 (목록 + 지도 테스트용)
struct RouteDummyData {
    static let samples: [RouteSummary] = [
        RouteSummary(
            title: "강릉 해안 여행 루트",
            origin: RoutePlace(name: "강릉역", lat: 37.764, lng: 128.899),
            waypoints: [
                RoutePlace(name: "안목해변", lat: 37.772, lng: 128.946),
                RoutePlace(name: "정동진 해변", lat: 37.689, lng: 129.034)
            ],
            destination: RoutePlace(name: "주문진항", lat: 37.892, lng: 128.829),
            categoryCounts: [
                "관광명소": 3,
                "식당": 2,
                "숙박": 1
            ]
        ),
        RouteSummary(
            title: "서울 도심 투어",
            origin: RoutePlace(name: "서울역", lat: 37.554, lng: 126.970),
            waypoints: [
                RoutePlace(name: "명동성당", lat: 37.563, lng: 126.987),
                RoutePlace(name: "남산타워", lat: 37.551, lng: 126.988)
            ],
            destination: RoutePlace(name: "이태원", lat: 37.534, lng: 126.994),
            categoryCounts: [
                "관광명소": 4,
                "식당": 1,
                "숙박": 2
            ]
        ),
        RouteSummary(
            title: "부산 해안 드라이브",
            origin: RoutePlace(name: "해운대", lat: 35.163, lng: 129.163),
            waypoints: [
                RoutePlace(name: "광안리 해변", lat: 35.153, lng: 129.118),
                RoutePlace(name: "송도해수욕장", lat: 35.075, lng: 129.020)
            ],
            destination: RoutePlace(name: "태종대", lat: 35.058, lng: 129.086),
            categoryCounts: [
                "관광명소": 5,
                "식당": 3,
                "숙박": 1
            ]
        )
    ]
}
