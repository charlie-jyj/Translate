//
//  Constants.swift
//  Translate
//
//  Created by 정유진 on 2022/05/30.
//

import Foundation

struct APIConstants {
    static let shared = APIConstants()
    let clientIDKey = "X-Naver-Client-Id"
    let clientSKey = "X-Naver-Client-Secret"
    let requestURL = "https://openapi.naver.com/v1/papago/n2mt"
    let values: [String: String]
    
    init() {
        values = [
            "Content-Type": "application/json",
            "Accept": "*/*",
            self.clientIDKey : "kZy2lsJlNqyWMFYMztPA",
            self.clientSKey : "muwwc9uNCj"
        ]
    }
}
