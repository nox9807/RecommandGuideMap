//
//  SearchModel.swift
//  RecommandGuideMap
//
//  Created by JaeYeongMAC on 11/14/25.
//

import Foundation

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
