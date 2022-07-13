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
class CoreDataViewModel {
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate!.persistentContainer
    }()
    
    let disposeBag = DisposeBag()
    let translateViewModel = TranslateViewModel()
    let bookmarkViewModel = BookmarkViewModel()
    var context: NSManagedObjectContext!
    
    init() {
        openDatabase()
        translateViewModel
            .tapBookmarkButton
            .subscribe(onNext: { [weak self] (bookmark) in
                print(bookmark.sourceContent,"=>",bookmark.targetContent)
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
        
        // bookmark viewDidLoad 시점에 fetch
        bookmarkViewModel
            .viewdidload
            .subscribe(onNext: { (signal) in
                if signal == "viewDidLoad" {
                    let completion = {[weak self] (result: FetchItemsResult) -> Void in
                        switch result {
                        case .success(let items):
                            print("viewdidload fetch: \(items)")
                            if let _bookmarkViewModel = self?.bookmarkViewModel,
                               let _disposeBag = self?.disposeBag {
                                Observable.just(items)
                                    .bind(to: _bookmarkViewModel.fetchData)
                                    .disposed(by: _disposeBag)
                                
                                Observable.just(items.count)
                                    .bind(to: _bookmarkViewModel.fetchDataCount)
                                    .disposed(by: _disposeBag)
                                
                                Observable.just("fetched")
                                    .bind(to: _bookmarkViewModel.isFetched)
                                    .disposed(by: _disposeBag)
                            }
                        case .failure(let error):
                            print("fetch error: \(error.localizedDescription)")
                        }
                    }
                    
                    self.fetchPersistedData(completion: completion)
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
            
            // bookmark 저장 후 fetch
            let completion = {[weak self] (result: FetchItemsResult) -> Void in
                switch result {
                case .success(let items):
                    print("after save: \(items)")
                    if let _bookmarkViewModel = self?.bookmarkViewModel,
                       let _disposeBag = self?.disposeBag {
                        Observable.just(items)
                            .bind(to: _bookmarkViewModel.fetchData)
                            .disposed(by: _disposeBag)
                        
                        Observable.just(items.count)
                            .bind(to: _bookmarkViewModel.fetchDataCount)
                            .disposed(by: _disposeBag)
                    }
                case .failure(let error):
                    print("fetch error: \(error.localizedDescription)")
                }
            }
            
            fetchPersistedData(completion: completion)
        }
    }
    
    //TOBE: fetch 결과 전달 방식을 clousure => rx로 수정
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
    
    enum FetchItemsResult {
        case success([Item])
        case failure(Error)
    }

}
