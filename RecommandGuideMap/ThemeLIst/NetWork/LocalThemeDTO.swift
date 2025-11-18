/// [refactor] JSON DTO 구조 정의 및 도메인 모델(Location/Theme) 변환 메서드 추가
/// - LocalPlaceDTO → Location
/// - ThemeDTO → Theme
//
//  LocalPlaceDTO.swift
//  RecommandGuideMap
//
//  Created by 이찬희 on 11/13/25.
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
    let imageURL: String 
}

struct ThemeDTO: Decodable {
    let id: String
    let title: String
    let coverURL: String?
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
            imageURL: imageURL,
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
            coverURL: coverURL ?? "",
            locations: locations
        )
    }
}
