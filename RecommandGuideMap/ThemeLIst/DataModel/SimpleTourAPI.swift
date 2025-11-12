// SimpleTourAPI.swift
// 초간단 1파일 + 1헬퍼 + 1API (searchKeyword)
// - _type=json 강제
// - 결과 0건일 때 "items": ""(빈 문자열)도 안전 디코딩
// - DTO 내부에서 Location으로 매핑까지 해 줌

import Foundation

// ✅ 본인 "일반(Decoding)키, 평문"을 그대로 넣으세요 (인코딩키/<>/공백/줄바꿈 X)
private let TOUR_BASE = "https://apis.data.go.kr/B551011/KorService2"
private let TOUR_SERVICE_KEY = "536ee065f39affbbdae629132adf070de5704a369f4ea5a02e9a9f80d1f10a53"

// MARK: - Public API
enum SimpleTourAPI {
    
    /// Postman과 동일 호출: searchKeyword2 + _type=json + keyword
    /// - Returns: Location 배열 (좌표/대표사진 없는 항목은 필터)
    static func searchKeyword(_ keyword: String,
                              rows: Int = 10,
                              page: Int = 1) async throws -> [Location] {
        
        let params: [String:String] = [
            "serviceKey": TOUR_SERVICE_KEY,
            "MobileOS": "IOS",
            "MobileApp": "RecommandGuideMap",
            "_type": "json",
            "keyword": keyword,
            "numOfRows": "\(rows)",
            "pageNo": "\(page)"
            // 필요 시 "contentTypeId": "39"
        ]
        
        let dto: SearchDTO = try await getJSON("searchKeyword2", params)
        
        // API 정상 코드 체크
        guard dto.response.header.resultCode == "0000" else {
            throw NSError(domain: "TourAPI",
                          code: 200,
                          userInfo: [NSLocalizedDescriptionKey: "[API] \(dto.response.header.resultCode) \(dto.response.header.resultMsg)"])
        }
        
        // items 안전 추출
        let places: [SearchDTO.Place] = {
            switch dto.response.body.items {
                case .list(let arr): return arr
                case .empty:         return []
            }
        }()
        
        // DTO -> Location 매핑 (+유효성 필터)
        let locations: [Location] = places.compactMap { p in
            guard
                let sx = p.mapx, let sy = p.mapy,
                let x = Double(sx), let y = Double(sy),
                let img = p.firstimage, !img.isEmpty
            else { return nil }
            
            return Location(
                id: p.contentid ?? UUID().uuidString,
                name: p.title ?? "(이름없음)",
                rating: Double.random(in: 3.8...5.0),
                distanceText: p.addr1 ?? "-",
                address: p.addr1 ?? (p.addr2 ?? "-"),
                description: p.title ?? "",
                photoImage: nil,
                photoURL: URL(string: img),
                lat: y, lng: x
            )
        }
        
        return locations
    }
}

// MARK: - Minimal HTTP helper (디버깅 로그 포함)
private func getJSON<T: Decodable>(_ path: String,
                                   _ params: [String:String],
                                   decode: T.Type = T.self) async throws -> T {
    var comp = URLComponents(string: "\(TOUR_BASE)/\(path)")!
    
    // serviceKey는 항상 첫 번째에 (가독성)
    var items: [URLQueryItem] = [URLQueryItem(name: "serviceKey", value: params["serviceKey"])]
    for (k, v) in params where k != "serviceKey" {
        items.append(URLQueryItem(name: k, value: v))
    }
    comp.queryItems = items
    
    let url = comp.url!
    
    let (data, resp) = try await URLSession.shared.data(from: url)
    guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }
    
    // 🔎 디버깅: 최종 URL / 상태 / RAW 바디
    print("🔗 \(url.absoluteString)")
    print("🧾 STATUS:", http.statusCode)
    if let s = String(data: data, encoding: .utf8) { print("🧾 BODY:", s.prefix(2000)) }
    
    guard (200...299).contains(http.statusCode) else { throw URLError(.badServerResponse) }
    
    return try JSONDecoder().decode(T.self, from: data)
}

// MARK: - Flexible DTO (items가 "" 또는 {item:...} 모두 수용)
private struct SearchDTO: Decodable {
    struct Response: Decodable { let header: Header; let body: Body }
    struct Header: Decodable { let resultCode: String; let resultMsg: String }
    
    struct Body: Decodable {
        let items: ItemsBox
        let numOfRows: Int?
        let pageNo: Int?
        let totalCount: Int?
    }
    
    /// "items": ""  또는  { "item": {...} } / { "item": [ ... ] }
    enum ItemsBox: Decodable {
        case empty
        case list([Place])
        
        init(from decoder: Decoder) throws {
            // 1) 빈 문자열 대응
            if let s = try? decoder.singleValueContainer().decode(String.self),
               s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                self = .empty
                return
            }
            // 2) 객체 컨테이너 파싱
            let c = try decoder.container(keyedBy: CodingKeys.self)
            if let one = try? c.decode(Place.self, forKey: .item) {
                self = .list([one])
            } else if let many = try? c.decode([Place].self, forKey: .item) {
                self = .list(many)
            } else {
                self = .empty
            }
        }
        private enum CodingKeys: String, CodingKey { case item }
    }
    
    struct Place: Decodable {
        let contentid: String?
        let title: String?
        let addr1: String?
        let addr2: String?
        let mapx: String?
        let mapy: String?
        let firstimage: String?
    }
    
    let response: Response
}
