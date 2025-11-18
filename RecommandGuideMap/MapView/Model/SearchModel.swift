//
//  SearchModel.swift
//  RecommandGuideMap
//
//  Created by JaeYeongMAC on 11/14/25.
//

import Foundation

/// 네이버 로컬 검색 API를 사용하여 장소를 검색하는 모델 객체.
///
/// - `search(keyword:)` 메소드를 통해 키워드를 넘기면
///   `SearchResponse.SearchItem` 배열을 비동기로 반환한다.
///   키워드를 이용해서 네이버 로컬 검색 API를 호출한다.
///
/// - Parameter keyword: 검색할 키워드
/// - Returns: 검색 결과에서 필요한 필드만 추린 `SearchItem` 배열.
class SearchModel {
    let clientId: String
    let clientSecret: String
    let api = NaverLocalSearch()
    
    init() {
        self.clientId = Bundle.main.object(forInfoDictionaryKey: "NAVER_CLIENT_ID") as? String ?? ""
        self.clientSecret = Bundle.main.object(forInfoDictionaryKey: "NAVER_CLIENT_SECRET") as? String ?? ""
    }
    
    func search(keyword: String) async throws -> [SearchResponse.SearchItem] {
        guard keyword.trimmingCharacters(in: .whitespacesAndNewlines).count >= 1 else { return [] }
        return try await api.search(query: keyword, clientId: clientId, clientSecret: clientSecret)
    }
}
