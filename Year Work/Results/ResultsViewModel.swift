//
//  ResultsViewModel.swift
//  Year Work
//
//  Created by Bohdan Arkhypchuk on 04.05.2023.
//

import SwiftUI

struct ResultsViewModel {
    
    enum DyslexiaResult: String {
        
        case low, medium, high
    }
    
    @Binding var model: TestingModel
    
    let maxScore: Double = {
        var maxTotalScore = 0.0
        
        for task in TestTask.allCases {
            maxTotalScore += task.maxScore
        }
        
        return maxTotalScore
    }()
    
    func dyslexiaScoreResult() -> DyslexiaResult {
        let totalScore = totalScore()
        
        switch totalScore {
        case 0...40:
            return .high
            
        case 40...80:
            return .medium
            
        case 80...100:
            return .low
            
        default:
            return .low
        }
    }
    
    private func totalScore() -> Double {
        var totalScore = 0.0

        
        for task in TestTask.allCases {
            let taskScore = taskScore(task: task)
            totalScore += taskScore
        }
        
        return (totalScore / maxScore) * 100
    }
    
    func barTaskScore(task: TestTask) -> Double {
        return 100 * (model.completedTasks.first(where: { $0.task == task.rawValue })?.score ?? 0) / task.maxScore
    }
    
    private func taskScore(task: TestTask) -> Double {
        return model.completedTasks.first(where: { $0.task == task.rawValue })?.score ?? 0
    }
}
