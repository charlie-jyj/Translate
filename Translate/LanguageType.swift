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
    case Spainish
    
    var id: String {
        return self.rawValue
    }
    
}
