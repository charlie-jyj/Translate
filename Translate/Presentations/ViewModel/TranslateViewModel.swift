//
//  TranslateViewModel.swift
//  Translate
//
//  Created by 정유진 on 2022/04/28.
//

import RxSwift
import RxCocoa
import CoreData
import Alamofire

struct TranslateViewModel {
    
    let disposeBag = DisposeBag()
  
    //subViewModels
    var sourceTextViewModel = SourceTextViewModel()
    var apiViewModel = APIViewModel()
    
    // viewModel -> view
    let sourceLabelText: Driver<String>
    let targetLabelText: Driver<String>
    let languageList: Signal<[LanguageType]>
    let changeLanguageButton: Signal<ButtonStyle>
    let presentRecordedText: Driver<String>
   
    // view -> viewModel
    let tapLanguageButton = PublishRelay<ButtonType>()
    let tapAlertActionSheetLanguage = PublishRelay<LanguageType>()
    let tapBookmarkButton = PublishRelay<Bookmark>()
    let sourceLanguage = BehaviorRelay<LanguageType>(value:.Korean)
    let targetLanguage = BehaviorRelay<LanguageType>(value: .English)
    
    // viewModel -> vieModel
    let recordedText = BehaviorRelay<String>(value: "")
    
    init() {
        sourceLabelText = sourceTextViewModel
            .documentData
            .asDriver(onErrorJustReturn: "")
        
        presentRecordedText = recordedText
            .asDriver(onErrorJustReturn: "")
        
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
            
        // alamofire api 통신
        Observable.combineLatest(
            sourceLanguage,
            targetLanguage,
            sourceLabelText.asObservable(),
            resultSelector: {source, target, text   -> RequestMessage in
                let source = source.code
                let target = target.code
                let paramerters = RequestMessage(source: source, target: target, text: text)
             
                return paramerters
            })
        .bind(to: apiViewModel.beforeTranslated)
        .disposed(by: disposeBag)
         
        // 번역 후 text
        targetLabelText = apiViewModel
            .afterTranslated
            .map { $0.text }
            .asDriver(onErrorJustReturn: "translated text load is failed")
    }
}
