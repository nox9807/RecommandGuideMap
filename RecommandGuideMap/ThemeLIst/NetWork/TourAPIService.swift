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

        let dto: SearchDTO = try await TourAPIClient.shared.fetch(
            endpoint: "searchKeyword2",
            queryParameters: parameters
        )

        let locations = try TourDataMapper.locations(from: dto)
        return locations
    }
}
