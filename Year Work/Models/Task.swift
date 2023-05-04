//
//  Enums.swift
//  Year Work
//
//  Created by Bohdan Arkhypchuk on 13.03.2023.
//

import Foundation

enum TestTask: String, CaseIterable, Codable {
    
    case vision, rythms, speech, numbers, orientation
    
    var description: String {
        switch self {
        case .vision:
            return "Повтори своїми руками жести відображені на екрані"
            
        case .orientation:
            return "Піднімай руку з тої сторони де підсвічується екран"
                
        case .speech:
            return "Читай в слух те що бачиш посередині екрану"
                
        case .numbers:
            return "Запамʼятовуй послідовність цифр та відтворюй її по памʼяті"
                
        case .rythms:
            return "Запамʼятовуй звуки та послідовність ритмів і відтворюй їх у такому ж порядку"
        }
    }

    var maxScore: Double {
        switch self {
        case .vision, .orientation, .numbers, .rythms:
            return 10
    
        case .speech:
            return 30
    
        }
    }
}
