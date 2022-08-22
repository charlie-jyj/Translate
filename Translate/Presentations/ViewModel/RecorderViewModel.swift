//
//  RecorderViewModel.swift
//  Translate
//
//  Created by 정유진 on 2022/08/11.
//

import Foundation
import RxSwift
import RxCocoa

class RecorderViewModel {
    var speechRecognizer: SpeechRecognizer
    let translateViewModel: TranslateViewModel
    let disposeBag = DisposeBag()
    
    // viewModel -> view
    let recordedText:  Signal<String>
    
    // view -> viewModel
    let tapRecorderButton = PublishRelay<recorderStatus>()
    
    // viewModel -> viewModel
    let transcript = PublishSubject<String>()
   
    typealias recorderStatus = RecorderViewController.RecorderStatus
    
    init(speechRecognizer: SpeechRecognizer, subViewModel: TranslateViewModel) {
        self.speechRecognizer = speechRecognizer
        self.translateViewModel = subViewModel
        
        self.recordedText = speechRecognizer.transcript
            .map { $0 }
            .asSignal(onErrorJustReturn: "")
        
        tapRecorderButton
            .subscribe(onNext: { [weak self] status in
                guard let self = self else { return }
                
                if status == .start {
                    speechRecognizer.reset()
                    speechRecognizer.transcribe()
                } else if status == .stop {
                    speechRecognizer.stopTranscribing()
                    speechRecognizer.transcript
                        .bind(to: self.translateViewModel.recordedText)
                        .disposed(by: self.disposeBag)
                    speechRecognizer.transcript
                        .bind(to: self.translateViewModel.sourceTextViewModel.documentData)
                        .disposed(by: self.disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        
    }
    
}

