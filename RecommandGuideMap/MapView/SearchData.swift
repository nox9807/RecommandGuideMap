//
//  SearchData.swift
//  RecommandGuideMap
//
//  Created by JaeYeongMAC on 11/10/25.
//

import Foundation

struct SearchResponse: Decodable {
    struct SearchInfo: Decodable {
        let title: String
        let link: URL
        let category: String
        let description: String
        let telephone: String
        let address: String
        let roadAddress: String
        let mapx: String
        let mapy: String
    }
    let lastBuildDate : Date
    let total: Int
    let start: Int
    let display: Int
    let items: [SearchInfo]
}
struct NaverLocalSearch {
    let clientId: String
    let clientSecret: String
    
    
    func search(query: String, display: Int = 5) -> Void {
        var url = URLComponents(string: "https://openapi.naver.com/v1/search/local.json")!
        url.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "display", value: "\(display)"),
        ]
        
        var request = URLRequest(url: url.url!)
        request.setValue(clientId, forHTTPHeaderField: "X-Naver-Client-Id")
        request.setValue(clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
    }
}
