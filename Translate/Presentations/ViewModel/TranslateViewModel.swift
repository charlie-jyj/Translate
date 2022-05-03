//
//  TranslateViewModel.swift
//  Translate
//
//  Created by 정유진 on 2022/04/28.
//

import RxSwift
import RxCocoa


struct LanguageOption {
    let type: String
    let title: String
}

struct TranslateViewModel {
    let disposeBag = DisposeBag()
  
    //subViewModels
    let sourceTextViewModel = SourceTextViewModel()
    
    // viewModel -> view
    let sourceLabelText: Driver<String>
    let languageList: Signal<[LanguageType]>
    let changeLanguageButton: Signal<LanguageOption>
    
    // view -> viewModel
    let tapLanguageButton = PublishRelay<String>()
    let tapAlertActionSheetLanguage = PublishRelay<String>()
    let sourceLanguage = BehaviorRelay<LanguageType>(value:.Korean)
    let targetLanguage = BehaviorRelay<LanguageType>(value: .English)
    
    init() {
        sourceLabelText = sourceTextViewModel
            .documentData
            .asDriver(onErrorJustReturn: "source label fill error")
        
        let languageAllCases = Observable.just(LanguageType.allCases)
        
        languageList = tapLanguageButton
            .filter({$0 != ""})
            .withLatestFrom(languageAllCases)
            .map{ $0 }
            .asSignal(onErrorJustReturn: [])
        
        changeLanguageButton = Observable
            .combineLatest(tapLanguageButton, tapAlertActionSheetLanguage) { first, last in
                LanguageOption(type: first, title: last)
            }
            .asSignal(onErrorJustReturn: LanguageOption(type: "source", title: "korean"))
            
        sourceLanguage
            .subscribe({
                print("source: \($0)")
            })

        targetLanguage
            .subscribe({
                print("target: \($0)")
            })
        
    }
    
}
