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
    let imageName: String
}

struct ThemeDTO: Decodable {
    let id: String
    let title: String
    let coverImageName: String?
    let locations: [LocalPlaceDTO]
}

extension LocalPlaceDTO {
    /// LocalPlaceDTO → 앱에서 실제로 사용하는 Location
    func toLocation() -> Location {
        Location(
            id: id,
            name: name,
            rating: Double(rating),
            distanceText: address,
            address: address,
            description: description,
            photoImage: UIImage(named: imageName),
            photoURL: nil,
            lat: lat,
            lng: lng
        )
    }
}

extension ThemeDTO {
   
    func toTheme() -> Theme {
        let locations = self.locations.map { $0.toLocation() }
        let coverImage = coverImageName.flatMap { UIImage(named: $0) }
        
        return Theme(
            id: id,
            title: title,
            coverImage: coverImage,
            coverURL: nil,
            viewCount: locations.count,
            locations: locations
        )
    }
}
