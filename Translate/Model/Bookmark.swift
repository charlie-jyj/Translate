//
//  Bookmark.swift
//  Translate
//
//  Created by 정유진 on 2022/05/24.
//

import Foundation

public class Bookmark: NSObject, NSCoding {
    
    var sourceLanguage: LanguageType
    var targetLanguage: LanguageType
    var sourceContent: String
    var targetContent: String
    
    enum Keys: String {
        case sourceLanguage = "sourceLanguage"
        case targetLanguage = "targetLanguage"
        case sourceContent = "sourceContent"
        case targetContent = "targetContent"
    }
    
    init(_sourceLanguage: LanguageType, _targetLanguage: LanguageType, _sourceContent: String, _targetContent: String) {
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
        sourceLanguage = coder.decodeObject(forKey: "sourceLanguage") as! LanguageType
        targetLanguage = coder.decodeObject(forKey: "targetLanguage") as! LanguageType
        sourceContent = coder.decodeObject(forKey: "sourceContent") as! String
        targetContent = coder.decodeObject(forKey: "targetContent") as! String
        
    }
    
    
}
