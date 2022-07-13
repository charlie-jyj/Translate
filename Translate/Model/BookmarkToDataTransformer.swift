//
//  BookmarkToDataTransformer.swift
//  Translate
//
//  Created by 정유진 on 2022/07/13.
//

import Foundation

class BookmarkToDataTransformer: NSSecureUnarchiveFromDataTransformer {
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override class func transformedValueClass() -> AnyClass {
        return Bookmark.self
    }
    
    override class var allowedTopLevelClasses: [AnyClass] {
        return [Bookmark.self, NSString.self]
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else {
            fatalError("Wrong data type: value must be a Data object; received \(type(of: value))")
        }
        return super.transformedValue(data)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let bookmark = value as? Bookmark else {
            fatalError("Wrong data type: value must be a Bookmark object; received \(type(of: value))")
        }
        return super.reverseTransformedValue(bookmark)
    }
}

extension NSValueTransformerName {
    static let bookmarkToDataTransformer = NSValueTransformerName(rawValue: "BookmarkToDataTransformer")
}
