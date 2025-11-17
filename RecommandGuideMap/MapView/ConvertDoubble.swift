//
//  ConvertDoubble.swift
//  RecommandGuideMap
//
//  Created by JaeYeongMAC on 11/13/25.
//

import Foundation

// MARK: - 좌표값 문자열을 소수로 치환하는 메소드
func tm128Double(from raw: String, Digits: Int = 7) -> Double? {
    
    if raw.contains(".") {
        return Double(raw)
    }
    
    let digits = raw.filter(\.isNumber)
    guard !digits.isEmpty else { return nil }
    
    if digits.count <= Digits {
        let frac = String(repeating: "0", count: Digits - digits.count) + digits
        return Double("0.\(frac)")
    } else {
        let splitIdx = digits.index(digits.endIndex, offsetBy: -Digits)
        let frontPart = String(digits[..<splitIdx])
        let backPart = String(digits[splitIdx...])
        
        return Double("\(frontPart).\(backPart)")
    }
}


