//
//  LocalPlaceDTO.swift
//  RecommandGuideMap
//
//  Created by 이찬희 on 11/13/25.
//
//  LocalPlaceDTO.swift
//  RecommandGuideMap
//

import Foundation
import UIKit

struct LocalPlaceDTO: Decodable {
    let id: String
    let name: String
    let rating: Int
    let address: String
    let description: String
    let lat: Double
    let lng: Double
    let imageURL: String  // ✅ 변경
}

struct ThemeDTO: Decodable {
    let id: String
    let title: String
    let coverURL: String?  // ✅ 변경
    let locations: [LocalPlaceDTO]
}

extension LocalPlaceDTO {
    func toLocation() -> Location {
        Location(
            id: id,
            name: name,
            rating: Double(rating),
            distanceText: address,
            address: address,
            description: description,
            imageURL: imageURL,  // ✅ 변경
            lat: lat,
            lng: lng
        )
    }
}

extension ThemeDTO {
    func toTheme() -> Theme {
        let locations = self.locations.map { $0.toLocation() }
        
        return Theme(
            id: id,
            title: title,
            coverURL: coverURL ?? "",  // ✅ 변경
            locations: locations
        )
    }
}
