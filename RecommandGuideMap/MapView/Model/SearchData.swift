//
//  SearchData.swift
//  RecommandGuideMap
//
//  Created by JaeYeongMAC on 11/10/25.
//

import Foundation

/// UI에서 사용하는 최소 필드만을 담은 검색 아이템.
///
/// - `title`: HTML 태그를 포함할 수 있는 장소 이름.
/// - `category`: "카페,디저트>카페" 와 같은 카테고리 문자열.
/// - `address`: 지번 주소.
/// - `roadAddress`: 도로명 주소.
/// - `mapx`, `mapy`: TM128 좌표(문자열). 필요 시 `tm128Double`로 변환.
struct SearchResponse: Decodable {
    struct SearchItem: Decodable {
        let title: String
        let category: String
        let address: String
        let roadAddress: String
        let mapx: String
        let mapy: String
    }
    let lastBuildDate : Date
    let total: Int
    let start: Int
    let display: Int
    let items: [SearchItem]
}

extension JSONDecoder {
    static var naverLocal: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss Z"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        return decoder
    }
}

/// 검색 과정에서 발생할 수 있는 에러들.
enum SearchError: Error {
    case inVaildURL
    case badStatus(Int)
}

/// 네이버 로컬 검색 API 요청을 담당하는 객체.
///
/// URLSession을 사용해 HTTPS 요청을 보내고,
/// JSON 응답을 `SearchResponse`로 디코딩한다.
struct NaverLocalSearch {
    let session = URLSession.shared
    
    /// 네이버 로컬 검색 API를 호출한다.
    ///
    /// - Parameters:
    ///   - query: 검색할 키워드.
    ///   - display: 한 번에 가져올 결과 개수(최대 5~10 정도).
    ///   - clientId: 네이버 로컬 검색용 Client ID.
    ///   - clientSecret: 네이버 로컬 검색용 Client Secret.
    /// - Returns: `SearchResponse.SearchItem` 배열.
    func search(query: String, display: Int = 5, clientId: String, clientSecret: String) async throws -> [SearchResponse.SearchItem]{
        guard var url = URLComponents(string: "https://openapi.naver.com/v1/search/local.json") else {
            throw SearchError.inVaildURL
        }
        
        url.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "display", value: "\(display)"),
        ]
        
        var request = URLRequest(url: url.url!)
        // 네이버 로컬 검색 전용 헤더 필드
        request.setValue(clientId, forHTTPHeaderField: "X-Naver-Client-Id")
        request.setValue(clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw SearchError.badStatus((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        
        let result = try JSONDecoder.naverLocal.decode(SearchResponse.self, from: data)
        print(result.items)
        return result.items
    }
}
