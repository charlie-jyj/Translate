//
//  LanguageType.swift
//  Translate
//
//  Created by 정유진 on 2022/05/06.
//

import Foundation

enum LanguageType: String, CaseIterable, Identifiable, Codable {
    case English
    case Korean
    case Japanese
    case Spanish
    
    var id: String {
        return self.rawValue
    }
    
    var title: String {
        switch self {
        case .English: return "영어"
        case .Korean: return "한국어"
        case .Japanese: return "일본어"
        case .Spanish: return "스페인어"
        }
    }
    
    var code: String {
        switch self {
        case .English: return "en"
        case .Korean: return "ko"
        case .Japanese: return "ja"
        case .Spanish: return "es"
        }
    }
    
}
