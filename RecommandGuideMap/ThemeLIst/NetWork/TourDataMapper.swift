//
//  TourDataMapper.swift
//  RecommandGuideMap
//
//  Created by 이찬희 on 11/13/25.
//

import Foundation

struct TourDataMapper {
    static func locations(from dto: SearchDTO) throws -> [Location] {
        guard dto.response.header.resultCode == "0000" else {
            let message = dto.response.header.resultMsg
            throw NSError(
                domain: "TourAPI",
                code: 200,
                userInfo: [NSLocalizedDescriptionKey: "[API] \(message)"]
            )
        }
        
        let places: [SearchDTO.Place] = {
            switch dto.response.body.items {
                case .list(let array): return array
                case .empty: return []
            }
        }()
        
        return places.compactMap { place in
            guard
                let longitudeString = place.mapx,
                let latitudeString  = place.mapy,
                let longitude = Double(longitudeString),
                let latitude  = Double(latitudeString),
                let imageURLString = place.firstimage,
                !imageURLString.isEmpty
            else {
                return nil
            }
            
            return Location(
                id: place.contentid ?? UUID().uuidString,
                name: place.title ?? "(이름없음)",
                rating: Double.random(in: 3.8...5.0),
                distanceText: place.addr1 ?? "-",
                address: place.addr1 ?? (place.addr2 ?? "-"),
                description: place.title ?? "",
                imageURL: imageURLString,  // ✅ 변경
                lat: latitude,
                lng: longitude
            )
        }
    }
}
