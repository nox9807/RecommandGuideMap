/// [feat] 공공데이터 TourAPI 연동 기능 구현
/// - search(keyword:) 비동기 검색 지원
/// - 응답 모델(TourResponse) 전체 정의
/// - 공공데이터 resultCode 확인 및 에러 처리
///
/// [refactor] TourPlace → Location 변환 로직 일원화
//
//  TourAPI.swift
//  RecommandGuideMap
//
//  Created by 이찬희 on 11/15/25.
//
import Foundation

// MARK: - Tour API Response
struct TourResponse: Codable {
    let response: ResponseBody
    
    struct ResponseBody: Codable {
        let header: Header
        let body: Body
    }
    
    struct Header: Codable {
        let resultCode: String
        let resultMsg: String
    }
    
    struct Body: Codable {
        let items: Items
        let numOfRows: Int?
        let pageNo: Int?
        let totalCount: Int?
    }

    enum Items: Codable {
        case empty
        case list([TourPlace])
        
        init(from decoder: Decoder) throws {
           
            if let string = try? decoder.singleValueContainer().decode(String.self),
               string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                self = .empty
                return
            }
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let places = try? container.decode([TourPlace].self, forKey: .item) {
                self = .list(places)
            } else if let place = try? container.decode(TourPlace.self, forKey: .item) {
                self = .list([place])
            } else {
                self = .empty
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
                case .empty:
                    try container.encode("", forKey: .item)
                case .list(let places):
                    try container.encode(places, forKey: .item)
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case item
        }
    }
    
    struct TourPlace: Codable {
        let contentid: String?
        let title: String?
        let addr1: String?
        let addr2: String?
        let mapx: String?
        let mapy: String?
        let firstimage: String?
    }
}

// MARK: - Tour API Client
final class TourAPI {
    static let shared = TourAPI()
    private init() {}
    
    private let baseURL = "https://apis.data.go.kr/B551011/KorService2"
    
    private var serviceKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "TOUR_SERVICE_KEY") as? String else {
            print("⚠️ TOUR_SERVICE_KEY not found")
            return ""
        }
        return key
    }
    /// [feat] 관광 정보 검색 API
    func search(keyword: String, rows: Int = 10, page: Int = 1) async throws -> [Location] {
        guard var components = URLComponents(string: "\(baseURL)/searchKeyword2") else {
            throw URLError(.badURL)
        }
        
        components.queryItems = [
            URLQueryItem(name: "serviceKey", value: serviceKey),
            URLQueryItem(name: "MobileOS", value: "IOS"),
            URLQueryItem(name: "MobileApp", value: "RecommandGuideMap"),
            URLQueryItem(name: "_type", value: "json"),
            URLQueryItem(name: "keyword", value: keyword),
            URLQueryItem(name: "numOfRows", value: "\(rows)"),
            URLQueryItem(name: "pageNo", value: "\(page)")
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        // API 호출
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // JSON 파싱
        let tourResponse = try JSONDecoder().decode(TourResponse.self, from: data)
        
        // 에러 체크
        guard tourResponse.response.header.resultCode == "0000" else {
            let msg = tourResponse.response.header.resultMsg
            throw NSError(domain: "TourAPI", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: msg])
        }
        
        // items 추출
        let places: [TourResponse.TourPlace] = {
            switch tourResponse.response.body.items {
                case .list(let array): return array
                case .empty: return []
            }
        }()
        
        // TourPlace → Location 변환
        return places.compactMap { place in
            guard let mapx = place.mapx, let mapy = place.mapy,
                  let lng = Double(mapx), let lat = Double(mapy),
                  let imageURL = place.firstimage, !imageURL.isEmpty else {
                return nil
            }
            
            return Location(
                id: place.contentid ?? UUID().uuidString,
                name: place.title ?? "(이름없음)",
                rating: Double.random(in: 3.8...5.0),
                distanceText: place.addr1 ?? "-",
                address: [place.addr1, place.addr2]
                    .compactMap { $0 }
                    .filter { !$0.isEmpty }
                    .joined(separator: " "),
                description: place.title ?? "",
                imageURL: imageURL,
                lat: lat,
                lng: lng
            )
        }
    }
}
