//
//  TranslateViewModel.swift
//  Translate
//
//  Created by 정유진 on 2022/04/28.
//

import RxSwift
import RxCocoa
import CoreData

struct TranslateViewModel {
    
    var container: NSPersistentContainer!
    let disposeBag = DisposeBag()
  
    //subViewModels
    var sourceTextViewModel = SourceTextViewModel()
    
    // viewModel -> view
    let sourceLabelText: Driver<String>
    let languageList: Signal<[LanguageType]>
    let changeLanguageButton: Signal<ButtonStyle>
    
    // view -> viewModel
    let tapLanguageButton = PublishRelay<ButtonType>()
    let tapAlertActionSheetLanguage = PublishRelay<LanguageType>()
    let sourceLanguage = BehaviorRelay<LanguageType>(value:.Korean)
    let targetLanguage = BehaviorRelay<LanguageType>(value: .English)
    
    init() {
        sourceLabelText = sourceTextViewModel
            .documentData
            .asDriver(onErrorJustReturn: "source label fill error")
        
        let languageAllCases = Observable.just(LanguageType.allCases)
        
        languageList = tapLanguageButton
            .withLatestFrom(languageAllCases)
            .map{ $0 }
            .asSignal(onErrorJustReturn: [])
        
        // 버튼의 종류(source/target), 언어의 종류
        changeLanguageButton = Observable
            .combineLatest(tapLanguageButton, tapAlertActionSheetLanguage) { first, last in
                ButtonStyle(type: first, label: last)
            }
            .asSignal(onErrorJustReturn: ButtonStyle(type: .source, label: .Korean))
            
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
