//
//  TabBarViewModel.swift
//  Translate
//
//  Created by 정유진 on 2022/05/09.
//

import UIKit
import RxSwift
import RxCocoa
import CoreData

//CoreData controller (create and manage)
class CoreDataViewModel: NSObject {
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BookmarkItems")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    let translateViewModel = TranslateViewModel()
    let bookmarkViewModel = BookmarkViewModel()
    
    func saveContext() {
        let viewContext = persistentContainer.viewContext
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error as NSError {
                fatalError("Unresolved error \(error.localizedDescription) \(error.userInfo)")
            }
        }
    }
    
    //TOBE: fetch 결과 전달 방식을 clousure => rx로 수정
    func fetchPersistedData(completion: @escaping (FetchItemsResult) -> Void) {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        let viewContext = persistentContainer.viewContext
        do {
            let allItems = try viewContext.fetch(fetchRequest)
            completion(.success(allItems))
        } catch {
            completion(.failure(error))
        }
    }
    
    enum FetchItemsResult {
        case success([Item])
        case failure(Error)
    }

}
