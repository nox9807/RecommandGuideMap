//
//  LocalPlaceDTO.swift
//  RecommandGuideMap
//
//  Created by 이찬희 on 11/13/25.
//
//  LocalPlaceDTO.swift
//  RecommandGuideMap
//
//  michelin.json 같은 로컬 JSON을 디코딩하기 위한 DTO들

import Foundation
import UIKit   // UIImage, Location, Theme 사용을 위해

/// JSON 안의 locations 배열 한 개를 표현하는 DTO
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

// MARK: - DTO → 도메인 모델(Location, Theme) 변환

extension LocalPlaceDTO {
    /// LocalPlaceDTO → 앱에서 실제로 사용하는 Location
    func toLocation() -> Location {
        Location(
            id: id,
            name: name,
            rating: Double(rating),
            distanceText: address,                 // 간단하게 주소를 재사용
            address: address,
            description: description,
            photoImage: UIImage(named: imageName), // Assets에서 로컬 이미지 로드
            photoURL: nil,
            lat: lat,
            lng: lng
        )
    }
}

extension ThemeDTO {
    /// ThemeDTO → 앱에서 사용하는 Theme
    func toTheme() -> Theme {
        let locations = self.locations.map { $0.toLocation() }
        let coverImage = coverImageName.flatMap { UIImage(named: $0) }
        
        return Theme(
            id: id,
            title: title,                // 🔥 리스트 카드에 보이는 타이틀
            coverImage: coverImage,      // 🔥 리스트 카드에 보이는 대표 이미지
            coverURL: nil,
            viewCount: locations.count,
            locations: locations
        )
    }
}
