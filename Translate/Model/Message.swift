//
//  Message.swift
//  Translate
//
//  Created by 정유진 on 2022/05/30.
//

import Foundation

struct RequestMessage: Encodable {
    var source: String
    var target: String
    var text: String
}

struct ResponseMessage: Decodable {
    var message: Message
    enum CodingKeys: String, CodingKey {
        case message
    }
}

struct Message: Decodable {
    var result: Result
    
    enum CodingKeys: String, CodingKey {
        case result
    }
}

struct Result: Decodable {
    var source: LanguageType
    var target: LanguageType
    @JSONDefaultWrapper.EmptyString var text: String // response에 없을 경우 기본값 ""으로 변환하는 property wrapper
    
    enum CodingKeys: String, CodingKey {
        case source = "srcLangType"
        case target = "tarLangType"
        case text = "translatedText"
    }
    
    init(from decoder: Decoder) throws {
        // response로 넘어온 값 type을 custom 해서 만든 type으로 바꾸기 위해 container 소환
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let _source = try container.decode(String.self, forKey: .source)
        let _target = try container.decode(String.self, forKey: .target)
        
        source = LanguageType.allCases.filter({ $0.code == _source }).first!
        target = LanguageType.allCases.filter({ $0.code == _target }).first!
        text = try container.decode(String.self, forKey: .text)
        
    }
}


