// SimpleTourAPI.swift
//  RecommandGuideMap
//
//  Created by 이찬희 on 11/10/25.
//
// Model.swift

import Foundation

private let TOUR_BASE = "https://apis.data.go.kr/B551011/KorService2"
private let TOUR_SERVICE_KEY = "536ee065f39affbbdae629132adf070de5704a369f4ea5a02e9a9f80d1f10a53"

enum SimpleTourAPI {
    
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
            
        ]
        
        let dto: SearchDTO = try await getJSON("searchKeyword2", params)
        
        guard dto.response.header.resultCode == "0000" else {
            throw NSError(domain: "TourAPI",
                          code: 200,
                          userInfo: [NSLocalizedDescriptionKey: "[API] \(dto.response.header.resultCode) \(dto.response.header.resultMsg)"])
        }
        
        let places: [SearchDTO.Place] = {
            switch dto.response.body.items {
                case .list(let arr): return arr
                case .empty:         return []
            }
        }()
        
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

private func getJSON<T: Decodable>(_ path: String,
                                   _ params: [String:String],
                                   decode: T.Type = T.self) async throws -> T {
    var comp = URLComponents(string: "\(TOUR_BASE)/\(path)")!
    
    var items: [URLQueryItem] = [URLQueryItem(name: "serviceKey", value: params["serviceKey"])]
    for (k, v) in params where k != "serviceKey" {
        items.append(URLQueryItem(name: k, value: v))
    }
    comp.queryItems = items
    
    let url = comp.url!
    
    let (data, resp) = try await URLSession.shared.data(from: url)
    guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }
    
    print("🔗 \(url.absoluteString)")
    print("🧾 STATUS:", http.statusCode)
    if let s = String(data: data, encoding: .utf8) { print("🧾 BODY:", s.prefix(2000)) }
    
    guard (200...299).contains(http.statusCode) else { throw URLError(.badServerResponse) }
    
    return try JSONDecoder().decode(T.self, from: data)
}

private struct SearchDTO: Decodable {
    struct Response: Decodable { let header: Header; let body: Body }
    struct Header: Decodable { let resultCode: String; let resultMsg: String }
    
    struct Body: Decodable {
        let items: ItemsBox
        let numOfRows: Int?
        let pageNo: Int?
        let totalCount: Int?
    }
    
    enum ItemsBox: Decodable {
        case empty
        case list([Place])
        
        init(from decoder: Decoder) throws {
            
            if let s = try? decoder.singleValueContainer().decode(String.self),
               s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                self = .empty
                return
            }
            
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
