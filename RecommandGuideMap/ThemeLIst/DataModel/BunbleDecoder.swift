//
//  BunbleDecoder.swift
//  RecommandGuideMap
//
//  Created by 이찬희 on 11/13/25.
//

import Foundation

extension Bundle {
    
    func decode<T: Decodable>(_ type: T.Type, file: String) throws -> T {
        // 1) 파일 URL 찾기
        guard let url = url(forResource: file, withExtension: "json") else {
            throw NSError(
                domain: "BundleDecode",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "\(file).json not found in bundle"]
            )
        }
        
        // 2) Data 읽기
        let data = try Data(contentsOf: url)
        
        // 3) JSONDecoder로 디코딩
        return try JSONDecoder().decode(T.self, from: data)
    }
}
