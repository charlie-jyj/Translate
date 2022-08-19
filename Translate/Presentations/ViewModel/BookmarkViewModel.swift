//
//  BookmarkViewModel.swift
//  Translate
//
//  Created by 정유진 on 2022/08/18.
//

import Foundation
import RxSwift
import RxCocoa

struct BookmarkViewModel {
    let disposeBag = DisposeBag()
    
    // viewModel -> view
    var bookmarkItems: Driver<[Item]>
    var bookmarkCount: Driver<Int>
    let showSaveAlert: Signal<SaveItemResult>
    
    // viewModel -> viewModel
    let isFetched = PublishSubject<Bool>()
    let fetchData = BehaviorSubject<[Item]>(value: [])
    let fetchDataCount = BehaviorSubject<Int>(value: 0)
    let isSaved = PublishSubject<Bool>()
    
    init() {
        bookmarkItems = isFetched
            .filter { $0 }
            .withLatestFrom(fetchData)
            .asDriver(onErrorJustReturn: [])
        
        bookmarkCount = isFetched
            .filter { $0 }
            .withLatestFrom(fetchDataCount)
            .asDriver(onErrorJustReturn: 0)
        
        showSaveAlert = isSaved
            .map {
                if $0 {
                    return SaveItemResult.success
                } else {
                    return SaveItemResult.failure
                }
            }
            .asSignal(onErrorJustReturn: SaveItemResult.failure)
    }
}
