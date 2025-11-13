
//
//  TourAPIClient.swift
//  RecommandGuideMap
//
//  Created by 이찬희 on 11/13/25.
//

import Foundation


final class TourAPIClient {
    
    static let shared = TourAPIClient()
    
    private init() {}
    
    private let baseURLString = "https://apis.data.go.kr/B551011/KorService2"
    private let urlSession: URLSession = .shared
    
    /// 공통 GET 요청 메서드
    /// - Parameters:
    ///   - endpoint: "searchKeyword2" 처럼 path
    ///   - queryParameters: serviceKey를 제외한 나머지 쿼리 파라미터
    /// - Returns: JSON을 디코딩한 DTO (T)
    func fetch<T: Decodable>(
        endpoint: String,
        queryParameters: [String: String]
    ) async throws -> T {
    
        var components = URLComponents(string: "\(baseURLString)/\(endpoint)")!
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "serviceKey", value: "536ee065f39affbbdae629132adf070de5704a369f4ea5a02e9a9f80d1f10a53")
        ]
        
        for (key, value) in queryParameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await urlSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
