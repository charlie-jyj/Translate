//
//  LanguageType.swift
//  Translate
//
//  Created by 정유진 on 2022/05/02.
//

import Foundation

enum ButtonType: String {
    case source
    case target
}

struct ButtonStyle {
    let type: ButtonType
    let label: LanguageType
}
