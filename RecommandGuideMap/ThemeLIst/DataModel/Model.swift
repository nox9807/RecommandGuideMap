//
//  Model.swift
//  RecommandGuideMap
//
//  Created by 이찬희 on 11/10/25.
//
// Model.swift
import UIKit

public struct Location {
    public let id: String
    public let name: String
    public let rating: Double
    public let distanceText: String
    public let address: String
    public let description: String
    public let photoImage: UIImage?
    public let photoURL: URL?
    public let lat: Double
    public let lng: Double
}

public struct Theme {
    public let id: String
    public let title: String
    public let coverImage: UIImage?
    public let coverURL: URL?
    public let viewCount: Int
    public let locations: [Location]
}
