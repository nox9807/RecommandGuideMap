//
//  RouteModel.swift
//  RecommandGuideMap
//
//  Created by JaeYeongMAC on 11/17/25.
//
import Foundation
import NMapsMap

// MARK: - Directions API 응답 모델
struct RouteResponse: Decodable {
    struct Route: Decodable {
        struct Summary: Decodable {
            let distance: Int
            let duration: Int
            let start: Location
            let goal: Location
            
            struct Location: Decodable {
                let location: [Double]
            }
        }
        let summary: Summary
        let path: [[Double]]
    }
    let route: [String: [Route]]
}

// MARK: - Directions API 호출 클래스
struct NaverDirections {
    private let session = URLSession.shared
    
    func fetchWalkingRoute(start: NMGLatLng, goal: NMGLatLng,
                           clientId: String, clientSecret: String) async throws -> (points: [NMGLatLng], summary: RouteResponse.Route.Summary) {
        guard var components = URLComponents(string: "https://naveropenapi.apigw.ntruss.com/map-direction/v1/walking") else {
            throw URLError(.badURL)
        }
        
        components.queryItems = [
            URLQueryItem(name: "start", value: "\(start.lng),\(start.lat)"),
            URLQueryItem(name: "goal", value: "\(goal.lng),\(goal.lat)")
        ]
        
        guard let url = components.url else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(clientId, forHTTPHeaderField: "X-Naver-Client-Id")
        request.setValue(clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
        
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let result = try JSONDecoder().decode(RouteResponse.self, from: data)
        
        guard let route = result.route["route"]?.first ?? result.route["traoptimal"]?.first else {
            throw URLError(.cannotFindHost)
        }
        
        let summary = route.summary
        let points = route.path.map { NMGLatLng(lat: $0[1], lng: $0[0]) }
        return (points, summary)
    }
}
