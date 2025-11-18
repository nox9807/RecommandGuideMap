//
//  SearchData.swift
//  RecommandGuideMap
//
//  Created by JaeYeongMAC on 11/10/25.
//

import Foundation

struct SearchResponse: Decodable {
    struct SearchItem: Decodable {
        let title: String
        //let link: String?
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

enum SearchError: Error {
    case inVaildURL
    case badStatus(Int)
}

struct NaverLocalSearch {
    let session = URLSession.shared
    
    func search(query: String, display: Int = 5, clientId: String, clientSecret: String) async throws -> [SearchResponse.SearchItem]{
        guard var url = URLComponents(string: "https://openapi.naver.com/v1/search/local.json") else {
            throw SearchError.inVaildURL
        }
        
        url.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "display", value: "\(display)"),
        ]
        
        var request = URLRequest(url: url.url!)
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
