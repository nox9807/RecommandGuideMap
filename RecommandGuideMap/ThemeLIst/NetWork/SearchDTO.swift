//
//  SearchDTO.swift
//  RecommandGuideMap
//
//  Created by 이찬희 on 11/13/25.
//

import Foundation

struct SearchDTO: Decodable {
    
    struct Response: Decodable {
        let header: Header
        let body: Body
    }
    
    struct Header: Decodable {
        let resultCode: String
        let resultMsg: String
    }
    
    struct Body: Decodable {
        let items: ItemsBox
        let numOfRows: Int?
        let pageNo: Int?
        let totalCount: Int?
    }
    
    enum ItemsBox: Decodable {
        case empty
        case list([Place])
        
        init(from decoder: Decoder) throws {
            
            if let singleString = try? decoder.singleValueContainer().decode(String.self),
               singleString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                self = .empty
                return
            }
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            if let one = try? container.decode(Place.self, forKey: .item) {
                self = .list([one])
            } else if let many = try? container.decode([Place].self, forKey: .item) {
                self = .list(many)
            } else {
                self = .empty
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case item
        }
    }
    
    struct Place: Decodable {
        let contentid: String?
        let title: String?
        let addr1: String?
        let addr2: String?
        let mapx: String?     // 경도(lng)
        let mapy: String?     // 위도(lat)
        let firstimage: String?
    }
    
    let response: Response
}
