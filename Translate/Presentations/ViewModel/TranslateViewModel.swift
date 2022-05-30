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
    
    // viewModel -> view
    let sourceLabelText: Driver<String>
    //let targetLabelText: Driver<String>
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
            
        // alamofire api 통신
        Observable.combineLatest(
            sourceLanguage,
            targetLanguage,
            sourceLabelText.asObservable(),
            resultSelector: {source, target, text   -> [String] in
                let source = source.code
                let target = target.code
                let paramerters = RequestMessage(source: source, target: target, text: text)
                var headers: HTTPHeaders = [:]
                for (key, value) in APIConstants.shared.values {
                    headers.add(name: key, value: value)
                }
                AF.request("https://openapi.naver.com/v1/papago/n2mt",
                           method: .post,
                           parameters: paramerters,
                           encoder: JSONParameterEncoder.default,
                           headers: headers
                )
                //.validate(statusCode: 200..<300)
                //.validate(contentType: ["application/json"])
                .responseDecodable(of: ResponseMessage.self) { response in
                    switch response.result {
                    case let .success(responseMessage):
                        let message = responseMessage.message.result
                        print("\(message.text)")
                    case let .failure(error):
                        //TOBE: error alert
                        print("\(error)")
                    }
                    
                }
                
                return ["\(source), \(target), \(text)"]
            })
        .subscribe(onNext: {
            print($0[0])
        })
        .disposed(by: disposeBag)
                
                
                
            
        
    }
    
}
