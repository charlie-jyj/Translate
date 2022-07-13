//
//  BookmarkViewModel.swift
//  Translate
//
//  Created by 정유진 on 2022/05/09.
//

import UIKit
import RxSwift
import RxCocoa
import CoreData

struct BookmarkViewModel {
    let disposeBag = DisposeBag()
    
    // viewModel -> view
    let bookmarkItems: Driver<[Item]>
    let isUpdated: Signal<Int>
    
    // view -> viewModel
    let viewdidload = PublishRelay<String>()
    
    // viewModel -> viewModel
    let fetchData = BehaviorSubject<[Item]>(value: [])
    let fetchDataCount = BehaviorSubject<Int>(value: 0)
    let isFetched = PublishSubject<String>()
    
    
    init() {
        fetchData
            .subscribe(onNext: { (items) in
                print("fetchdata subscribe", items.count)
            })
            .disposed(by: disposeBag)
        
        
        bookmarkItems = isFetched
            .withLatestFrom(fetchData)
            .distinctUntilChanged()
            .map { $0 }
            .asDriver(onErrorJustReturn: [])
        
        
        isUpdated = isFetched
            .withLatestFrom(fetchDataCount)
            .distinctUntilChanged()
            .map { $0 }
            .asSignal(onErrorJustReturn: 0)
    
    }
}
