//
//  Model.swift
//  RecommandGuideMap
//
//  Created by JaeYeongMAC on 11/5/25.
//

import Foundation

struct LocalItem: Decodable {
    let title: String
    let category: String
    let roadAddress: String
    let link: String
    let mapx: String
    let mapy: String
}
