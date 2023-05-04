//
//  SpeechResultModel.swift
//  Year Work
//
//  Created by Bohdan Arkhypchuk on 02.05.2023.
//

import Foundation

typealias SpeechPhrase = SpeechModel.SpeechPhrase

class SpeechResultsModel: ObservableObject {
    @Published var transcribedResults: [String] = []
    @Published var correctScore: Int = 0
    
    func storeTranscribedResult(_ result: String) {
        transcribedResults.append(result)
        if phrases.contains(where: { $0 == result }) {
            correctScore += 1
        }
    }
}

extension SpeechResultsModel {
    static var lengthInMinutes: Int { 3 }
    
    static var speechPhrases: [SpeechPhrase] {
        [
            "а", "м", "п", "к", "т", "г", "б", "ф", "х", "в", "н",
            "пре", "від", "зі", "на", "ко", "пі", "мо", "лу", "ре", "фо",
            "ліс", "трава", "машина", "вікно", "птах", "стіл", "книга", "квітка", "гора", "ручка",
        ]
            .map { SpeechPhrase(text: $0, isCompleted: false)}
    }
    
    var phrases: [String] {
        [
            "а", "м", "п", "к", "т", "г", "б", "ф", "х", "в", "н",
            "пре", "від", "зі", "на", "ко", "пі", "мо", "лу", "ре", "фо",
            "ліс", "трава", "машина", "вікно", "птах", "стіл", "книга", "квітка", "гора", "ручка",
        ]
    }
}

