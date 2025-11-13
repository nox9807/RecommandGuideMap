//
//  TourAPIService.swift
//  RecommandGuideMap
//
//  Created by 이찬희 on 11/13/25.
//

import Foundation

final class TourAPIService {

    static let shared = TourAPIService()

    private init() {}

    /// 키워드로 맛집 검색
    /// - Parameters:
    ///   - keyword: 검색 키워드 (예: "한식")
    ///   - rows: 페이지당 개수
    ///   - page: 페이지 번호
    func searchKeyword(
        _ keyword: String,
        rows: Int = 10,
        page: Int = 1
    ) async throws -> [Location] {

        let parameters: [String: String] = [
            "MobileOS": "IOS",
            "MobileApp": "RecommandGuideMap",
            "_type": "json",
            "keyword": keyword,
            "numOfRows": "\(rows)",
            "pageNo": "\(page)"
        ]

        // 1) API 호출 → DTO 받기
        let dto: SearchDTO = try await TourAPIClient.shared.fetch(
            endpoint: "searchKeyword2",
            queryParameters: parameters
        )

        // 2) DTO → [Location] 변환 (Mapper에 위임)
        let locations = try TourDataMapper.locations(from: dto)
        return locations
    }
}
