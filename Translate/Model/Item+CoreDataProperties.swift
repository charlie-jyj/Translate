//
//  Item+CoreDataProperties.swift
//  Translate
//
//  Created by 정유진 on 2022/05/24.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var bookmark: Bookmark
    @NSManaged public var createDate: String

}

extension Item : Identifiable {

}
