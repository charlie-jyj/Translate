//
//  RecorderViewModel.swift
//  Translate
//
//  Created by 정유진 on 2022/08/11.
//

import Foundation
import RxSwift
import RxCocoa

struct RecorderViewModel {
    let disposeBag = DisposeBag()
    let speechRecognizer: SpeechRecognizer?
    
    // view -> viewModel
    let tapLanguageButton = PublishRelay<String>()
    
    init() {
        speechRecognizer = SpeechRecognizer(locale: Locale(identifier: "ko_KR"))
    }
    
}

