//
//  JSONDefaultWrapper.swift
//  Translate
//
//  Created by 정유진 on 2022/05/30.
//

import Foundation

// Codable 통해 decode 할 때, 값이 존재하지 않을 경우 default 값을 주입한다.
protocol JSONDefaultWrapperAvailable {
    associatedtype ValueType: Decodable // 어떤 type일지 특정할 수 없기 때문에
    static var defaultValue: ValueType { get }
}

enum JSONDefaultWrapper {
    typealias EmptyString = Wrapper<JSONDefaultWrapper.DefaultString>
    
    enum DefaultString: JSONDefaultWrapperAvailable {
        static var defaultValue: String { "" }
    }
    
    @propertyWrapper
    struct Wrapper<T: JSONDefaultWrapperAvailable> {
        typealias ValueType = T.ValueType
        var wrappedValue: ValueType
        init() {
            wrappedValue = T.defaultValue
        }
    }
}

// decodable 한 type으로 만들어 준다.
extension JSONDefaultWrapper.Wrapper: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.wrappedValue = try container.decode(ValueType.self)
    }
}

// 해당 key에 대응되는 value가 없을 경우 기본값을 .init() 으로 할당
extension KeyedDecodingContainer {
    func decode<T: JSONDefaultWrapperAvailable>(_ type: JSONDefaultWrapper.Wrapper<T>.Type, forKey key: Key) throws -> JSONDefaultWrapper.Wrapper<T> {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }
}
