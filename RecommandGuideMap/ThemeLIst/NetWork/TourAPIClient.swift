
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
    
    private var serviceKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "TOUR_SERVICE_KEY") as? String else {
            print("⚠️ TOUR_SERVICE_KEY not found in Info.plist")
            return ""
        }
        return key
    }
    
    func fetch<T: Decodable>(
        endpoint: String,
        queryParameters: [String: String]
    ) async throws -> T {
        
        var components = URLComponents(string: "\(baseURLString)/\(endpoint)")!
    
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "serviceKey", value: serviceKey)
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
