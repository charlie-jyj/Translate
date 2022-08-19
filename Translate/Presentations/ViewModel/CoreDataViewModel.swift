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

enum FetchItemsResult {
    case success([Item])
    case failure(Error)
}

enum SaveItemResult {
    case success
    case failure
}

//CoreData controller (create and manage) 최상위 뷰모델
class CoreDataViewModel {
    
    var context: NSManagedObjectContext!
    private lazy var persistentContainer: NSPersistentContainer = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate!.persistentContainer
    }()
    let disposeBag = DisposeBag()
    
    // subviewModel
    let translateViewModel = TranslateViewModel()
    let bookmarkViewModel = BookmarkViewModel()
    
    // view -> viewModel
    let viewdidload = PublishRelay<Bool>()
    
    // viewModel -> viewModel
    
    init() {
        openDatabase()
        
        translateViewModel
            .tapBookmarkButton
            .subscribe(onNext: { [weak self] (bookmark) in
                if let _context = self?.context,
                   let createDate = self?.currentDateTime() {
                    let entity = NSEntityDescription.entity(forEntityName: "Item", in: _context)
                    let newBookmark = NSManagedObject(entity: entity!, insertInto: _context)
                    newBookmark.setValue(bookmark, forKey: "bookmark")
                    newBookmark.setValue(createDate, forKey: "createDate")
                    self?.saveContext()
                }
            })
            .disposed(by: disposeBag)
   
        //viewDidLoad 시점에 fetch
        viewdidload
            .subscribe(onNext: { (signal) in
                if signal {
                    let completion = {[weak self] (result: FetchItemsResult) -> Void in
                        switch result {
                        case .success(let items):
                            if  let _fetchData = self?.bookmarkViewModel.fetchData,
                                let _fetchDataCount = self?.bookmarkViewModel.fetchDataCount,
                                let _isFetched = self?.bookmarkViewModel.isFetched {
                        
                                _fetchData
                                    .on(.next(items))
                                
                                _fetchDataCount
                                    .on(.next(items.count))
                                
                                _isFetched
                                    .on(.next(true))
                            }
                        case .failure(let error):
                            print("fetch error: \(error.localizedDescription)")
                        }
                    }
                    
                    self.fetchPersistedData(completion: completion)
                } else {
                    print("view did load not occured")
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    func currentDateTime() -> String {
        let date = Date()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyyMMddHH:mm"
        return dateformatter.string(from: date)
    }
    
    func openDatabase() {
        context = persistentContainer.viewContext
    }
    
    func saveContext() {
        guard let viewContext = context
        else {
            print("context error occured")
            return }
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error as NSError {
                fatalError("Unresolved error \(error.localizedDescription) \(error.userInfo)")
            }
            
            let saveCompletion = {[weak self] (result: FetchItemsResult) -> Void in
                guard let self = self else { return }
                switch result {
                case .success(let items):
                    print("after save: \(items)")
                    
                    self.bookmarkViewModel.fetchData
                        .on(.next(items))
                    
                    self.bookmarkViewModel.fetchDataCount
                        .on(.next(items.count))
                    
                    self.bookmarkViewModel.isFetched
                        .on(.next(true))
                    
                    self.bookmarkViewModel.isSaved
                        .on(.next(true))
                    
                case .failure(let error):
                    print("fetch error: \(error.localizedDescription)")
                    
                    self.bookmarkViewModel.isFetched
                        .on(.next(false))
                    
                    self.bookmarkViewModel.isSaved
                        .on(.next(false))
                }
            }
            
            // bookmark 저장 후 fetch
            fetchPersistedData(completion: saveCompletion)
        }
    }
    
    func fetchPersistedData(completion: @escaping (FetchItemsResult) -> Void) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        fetchRequest.returnsObjectsAsFaults = false
        guard let viewContext = context else { return }
        do {
            guard let allItems = try viewContext.fetch(fetchRequest) as? [Item] else { return }
            completion(.success(allItems))
        } catch {
            completion(.failure(error))
        }
    }
}
