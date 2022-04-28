//
//  SourceTextViewModel.swift
//  Translate
//
//  Created by 정유진 on 2022/04/28.
//

import RxSwift
import RxCocoa

struct SourceTextViewModel {
    let disposeBag = DisposeBag()
    
    // view -> viewModel
    let doneButtonTapped = PublishRelay<String>()
    let sourceTextViewContent = PublishRelay<String?>()
    
    // viewModel -> viewModel
    let documentData = PublishSubject<String>()
    
    // super viewModel
    
    init() {
        doneButtonTapped
            .withLatestFrom(sourceTextViewContent)
            .distinctUntilChanged()
            .map { $0! }
            .bind(to: documentData)
            .disposed(by: disposeBag)
    }
    
}
