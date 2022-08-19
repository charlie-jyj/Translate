//
//  Extensions.swift
//  Translate
//
//  Created by 정유진 on 2022/08/18.
//

import Foundation

extension String {
    func convertRawToLanguageType() -> LanguageType {
        return LanguageType.allCases.filter({$0.rawValue == self}).first!
    }
    
    func convertTitleToLanguageType() -> LanguageType {
        return LanguageType.allCases.filter({$0.title == self}).first!
    }
    
    func converToLocale() -> Locale {
        let languageType = self.convertTitleToLanguageType()
        switch languageType {
        case .English: return Locale(identifier: "en_US")
        case .Japanese: return Locale(identifier: "ja_JP")
        case .Korean: return Locale(identifier: "ko_KR")
        case .Spanish: return Locale(identifier: "es_ES")
        }
    }
}

extension LanguageType {
    func convertToVoiceCode() -> String {
        switch self {
        case .English: return "en-US"
        case .Japanese: return "ja-JP"
        case .Korean: return "ko-KR"
        case .Spanish: return "es-ES"
        }
    }
}
