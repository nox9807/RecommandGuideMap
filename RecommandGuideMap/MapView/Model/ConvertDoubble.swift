//
//  ConvertDoubble.swift
//  RecommandGuideMap
//
//  Created by JaeYeongMAC on 11/13/25.
//

import Foundation

/// TM128 좌표 문자열을 일반 `Double` 값으로 변환하는 함수.
///
/// 네이버 검색 API에서 내려오는 `mapx`, `mapy` 값은
/// - 정수 + 소수 형태("126.978388") 또는
/// - TM128 정수 문자열("1269783881") 형태로 올 수 있다.
///
/// 이 함수는 입력이 이미 소수점(.)을 포함하고 있으면 그대로 `Double`로 변환하고,
/// 그 외에는 **마지막 `Digits` 자리만 소수부**로 보고 `Double`로 만들어 준다.
///
/// 예시:
/// ```swift
/// tm128Double(from: "1269783881")  // -> 126.9783881
/// tm128Double(from: "126.978388")  // -> 126.978388
func tm128Double(from raw: String, Digits: Int = 7) -> Double? {
    
    // 이미 소수점이 있으면 TM128이 아니라 경도/위도일 가능성이 높으므로 그대로 반환
    if raw.contains(".") {
        return Double(raw)
    }
    
    let digits = raw.filter(\.isNumber)
    guard !digits.isEmpty else { return nil }
    
    // 전체 길이가 Digits 이하면 0.xxxxxx 형태로 처리
    if digits.count <= Digits {
        let frac = String(repeating: "0", count: Digits - digits.count) + digits
        return Double("0.\(frac)")
    } else {
        // 끝에서 Digits 자리만 소수부로 사용
        let splitIdx = digits.index(digits.endIndex, offsetBy: -Digits)
        let frontPart = String(digits[..<splitIdx])
        let backPart = String(digits[splitIdx...])
        
        return Double("\(frontPart).\(backPart)")
    }
}


