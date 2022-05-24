//
//  Item+CoreDataClass.swift
//  Translate
//
//  Created by 정유진 on 2022/05/24.
//
//

import Foundation
import CoreData

@objc(Item)
public class Item: NSManagedObject {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createDate = DateFormatter().string(from: Date())
        bookmark = Bookmark(_sourceLanguage: .Korean, _targetLanguage: .English, _sourceContent: "", _targetContent: "")
    }
    
    func validateItem(_ item:Bookmark) {
        //TOBE: Bookmark의 content != "" 유효성 검사할 것
    }

}
