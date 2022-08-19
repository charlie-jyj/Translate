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
    private(set) var language: String?
    
    init(text source: String, languageType: LanguageType) {
        utterance = AVSpeechUtterance(string: source)
        language = languageType.convertToVoiceCode()
    }
    
    func speak() {
        guard let utterance = utterance,
              let language = language
        else { return }
        
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}

