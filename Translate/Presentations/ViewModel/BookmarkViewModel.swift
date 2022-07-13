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
    
    // view -> viewModel
    let viewdidload = PublishRelay<String>()
    
    // viewModel -> viewModel
    let fetchData = BehaviorSubject<[Item]>(value: [])
    
    
    init() {
        bookmarkItems = fetchData
            .asDriver(onErrorJustReturn: [])
        
        viewdidload
            .subscribe(onNext: { (signal) in
                
            })
    }
}
