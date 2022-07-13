//
//  Bookmark.swift
//  Translate
//
//  Created by 정유진 on 2022/05/24.
//

import Foundation

public class Bookmark: NSObject, NSCoding, NSSecureCoding {
    public static var supportsSecureCoding: Bool = true
    
    var sourceLanguage: String
    var targetLanguage: String
    var sourceContent: String
    var targetContent: String
    
    enum Keys: String {
        case sourceLanguage = "sourceLanguage"
        case targetLanguage = "targetLanguage"
        case sourceContent = "sourceContent"
        case targetContent = "targetContent"
    }
    
    init(_sourceLanguage: String, _targetLanguage: String, _sourceContent: String, _targetContent: String) {
        self.sourceLanguage = _sourceLanguage
        self.targetLanguage = _targetLanguage
        self.sourceContent = _sourceContent
        self.targetContent = _targetContent
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(sourceLanguage, forKey: "sourceLanguage")
        coder.encode(targetLanguage, forKey: "targetLanguage")
        coder.encode(sourceContent, forKey: "sourceContent")
        coder.encode(targetContent, forKey: "targetContent")
    }
    
    required public init?(coder: NSCoder) {
        sourceLanguage = coder.decodeObject(forKey: "sourceLanguage") as! String
        targetLanguage = coder.decodeObject(forKey: "targetLanguage") as! String
        sourceContent = coder.decodeObject(forKey: "sourceContent") as! String
        targetContent = coder.decodeObject(forKey: "targetContent") as! String
        
    }
}

