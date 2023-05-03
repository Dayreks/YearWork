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
        updateCorrectScore()
    }
    
    private func updateCorrectScore() {
        correctScore = transcribedResults.count 
    }
}

extension SpeechResultsModel {
    static var lengthInMinutes: Int { 1 }
    
    static var speechPhrases: [SpeechPhrase] {
        ["а", "та", "ла", "жах", "страх", "вибух", "а", "та", "ла", "жах", "страх", "вибух"]
            .map { SpeechPhrase(text: $0, isCompleted: false)}
    }
}

