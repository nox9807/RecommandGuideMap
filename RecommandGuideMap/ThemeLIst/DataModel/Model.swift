//
//  Model.swift
//  RecommandGuideMap
//
//  Created by 이찬희 on 11/10/25.
//
import UIKit

public struct Location: Codable {
    public let id: String
    public let name: String
    public let rating: Double
    public let distanceText: String
    public let address: String
    public let description: String
    public let imageURL: String  // ✅ 변경
    public let lat: Double
    public let lng: Double
}

public struct Theme: Codable {
    public let id: String
    public let title: String
    public let coverURL: String  // ✅ 변경
    public let locations: [Location]
    
    public var viewCount: Int { locations.count }
}
