//
//  LanguageType.swift
//  Translate
//
//  Created by 정유진 on 2022/05/02.
//

import Foundation

enum LanguageType: String, CaseIterable, Identifiable {
    case English
    case Korean
    case Japanese
    case Chinese
    
    var id: String {
        return self.rawValue
    }
    
    var title: String {
        switch self {
        case .English: return "영어"
        case .Korean: return "한국어"
        case .Japanese: return "일본어"
        case .Chinese: return "중국어"
        }
    }
    
}
