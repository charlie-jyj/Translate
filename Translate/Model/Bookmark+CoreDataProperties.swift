//
//  Bookmark+CoreDataProperties.swift
//  Translate
//
//  Created by 정유진 on 2022/05/09.
//
//

import Foundation
import CoreData


extension Bookmark {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bookmark> {
        return NSFetchRequest<Bookmark>(entityName: "Bookmark")
    }

    @NSManaged public var sourceLanguage: String?
    @NSManaged public var sourceText: String?
    @NSManaged public var targetLanguage: String?
    @NSManaged public var targetText: String?

}

extension Bookmark : Identifiable {

}
