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
    var context: NSManagedObjectContext!
    
    // viewModel -> view
    var bookmarkItems: Driver<[Item]>
    var bookmarkCount: Driver<Int>

    
    // view -> viewModel
    let viewdidload = PublishRelay<String>()
    
    // viewModel -> viewModel
    let fetchData = BehaviorSubject<[Item]>(value: [])
    let fetchDataCount = BehaviorSubject<Int>(value: 0)
    let isFetched = PublishSubject<String>()
    
    init() {
        
        isFetched
            .subscribe(onNext: { (message) in
                print(message)
            })
            .disposed(by: disposeBag)
        
        bookmarkItems = isFetched
            .withLatestFrom(fetchData)
            .map { $0 }
            .asDriver(onErrorJustReturn: [])
        
        bookmarkCount = isFetched
            .withLatestFrom(fetchDataCount)
            .asDriver(onErrorJustReturn: 0)
        
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
        
        //viewDidLoad 시점에 fetch
        viewdidload
            .subscribe(onNext: { (signal) in
                if signal == "viewDidLoad" {
                    let completion = {[weak self] (result: FetchItemsResult) -> Void in
                        switch result {
                        case .success(let items):
                            print("viewdidload fetch: \(items)")
                            if  let _fetchData = self?.fetchData,
                                let _fetchDataCount = self?.fetchDataCount,
                                let _isFetched = self?.isFetched {
                        
                                _fetchData
                                    .on(.next(items))
                                
                                _fetchDataCount
                                    .on(.next(items.count))
                                
                                _isFetched
                                    .on(.next("fetched"))
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
            
            let saveCompletion = {[weak self] (result: FetchItemsResult) -> Void in
                guard let self = self else { return }
                switch result {
                case .success(let items):
                    print("after save: \(items)")
                    
                    self.fetchData
                        .on(.next(items))
                    
                    self.fetchDataCount
                        .on(.next(items.count))
                    
                    self.isFetched
                        .on(.next("fetched after saving"))
                
                case .failure(let error):
                    print("fetch error: \(error.localizedDescription)")
                }
            }
            
            // bookmark 저장 후 fetch
            fetchPersistedData(completion: saveCompletion)
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
