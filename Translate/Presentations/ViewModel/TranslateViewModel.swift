//
//  TranslateViewModel.swift
//  Translate
//
//  Created by 정유진 on 2022/04/28.
//

import RxSwift
import RxCocoa

struct TranslateViewModel {
    let disposeBag = DisposeBag()
  
    //subViewModels
    let sourceTextViewModel = SourceTextViewModel()
    
    // viewModel -> view
    let sourceLabelText: Driver<String>
    
    init() {
        sourceLabelText = sourceTextViewModel
            .documentData
            .asDriver(onErrorJustReturn: "driver 이상해")
    }
    
}
