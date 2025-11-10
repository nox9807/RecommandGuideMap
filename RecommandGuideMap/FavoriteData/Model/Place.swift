//
//  Place.swift
//  RecommandGuideMap
//
//  Created by chaeyoonpark on 11/7/25.
//

import Foundation

struct Place: Codable, Hashable {
    let id: String          // Naver Place ID
    let name: String
    let category: String?
    let address: String?
    let lat: Double
    let lng: Double
    let imageURL: String?   // 대표 사진 하나만
}
