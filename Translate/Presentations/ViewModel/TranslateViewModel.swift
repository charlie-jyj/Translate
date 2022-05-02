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
    let languageList: Driver<[LanguageType]>
    
    // view -> viewModel
    let tapLanguageButton = BehaviorRelay<String>(value:"")
    let sourceLanguage = PublishRelay<String>()
    let targetLanguage = PublishRelay<String>()
    
    init() {
        sourceLabelText = sourceTextViewModel
            .documentData
            .asDriver(onErrorJustReturn: "driver 이상해")
        
        let languageAllCases = Observable.just(LanguageType.allCases)
        
        languageList = tapLanguageButton
            .filter({$0 != ""})
            .withLatestFrom(languageAllCases)
            .map{ $0 }
            .asDriver(onErrorJustReturn: [])
        
//        sourceLanguage
//            .subscribe({
//                print("source: \($0)")
//            })
//
//        targetLanguage
//            .subscribe({
//                print("target: \($0)")
//            })
        
    }
    
}
