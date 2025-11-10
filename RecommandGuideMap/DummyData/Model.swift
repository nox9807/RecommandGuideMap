//
//  Model.swift
//  RecommandGuideMap
//
//  Created by 이찬희 on 11/10/25.
//

import UIKit

struct Theme {
    let id: String
    let title: String
    let coverURL: URL        // 리스트 카드 썸네일(원격 이미지)
    let viewCount: Int
    let places: [Place]
}

struct Place {
    let id: String
    let name: String
    let rating: Double
    let distanceText: String
    let address: String
    let description: String
    let photo: UIImage       // 상세 카드의 배경(에셋 이미지)
    let lat: Double
    let lng: Double
}


