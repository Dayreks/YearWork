import Foundation

struct TestingModel: Identifiable, Codable {
    let id: UUID
    var title: String
    
    var phrases: [Phrase]
    var transcribedPhrases: [String] = []
    var lengthInMinutes: Int
    
    
    
    var completedTasks = Set<Tasks>()
    var theme: Theme
    
    init(id: UUID = UUID(), title: String, phrases: [String], lengthInMinutes: Int, theme: Theme) {
        self.id = id
        self.title = title
        self.phrases = phrases.map { Phrase(name: $0) }
        self.lengthInMinutes = lengthInMinutes
        self.theme = theme
    }
    
    mutating func markCompleted(task: Tasks) {
        completedTasks.insert(task)
    }
}

extension TestingModel {
    struct Phrase: Identifiable, Codable {
        let id: UUID
        var text: String
        
        init(id: UUID = UUID(), name: String) {
            self.id = id
            self.text = name
        }
    }
}

extension TestingModel {
    static let sampleData: [TestingModel] =
    [
        TestingModel(title: "TestingModelSample", phrases: ["Cathy", "Daisy", "Simon", "Jonathan"], lengthInMinutes: 1, theme: .navy),
    ]
}
