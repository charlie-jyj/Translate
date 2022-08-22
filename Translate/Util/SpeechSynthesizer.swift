//
//  SpeechSynthesizer.swift
//  Translate
//
//  Created by 정유진 on 2022/08/17.
//

import Foundation
import AVFoundation

class SpeechSynthesizer {
    private(set) var utterance: AVSpeechUtterance?
    let synthesizer = AVSpeechSynthesizer()
    
    init(text source: String, languageType: LanguageType) {
        utterance = AVSpeechUtterance(string: source)
        let language = languageType.convertToVoiceCode()
        self.utterance?.voice = AVSpeechSynthesisVoice(language: language)
        self.utterance?.rate = AVSpeechUtteranceDefaultSpeechRate
    }
    
    func speak() {
        guard let utterance = utterance
        else { return }
        synthesizer.speak(utterance)
    }
}

