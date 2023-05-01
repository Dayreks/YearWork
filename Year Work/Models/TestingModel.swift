import UIKit

class TestingModel: Identifiable {
    
    let persistenceController = PersistenceController.shared
    
    var title: String
    
    @Published var completedTasks: [CompletedTask] = []
    var phrases: [Phrase]
    var transcribedPhrases: [String] = []
    var lengthInMinutes: Int

    var theme: Theme
    
    init(title: String, phrases: [String], lengthInMinutes: Int, theme: Theme) {
        self.title = title
        self.phrases = phrases.map { Phrase(name: $0) }
        self.lengthInMinutes = lengthInMinutes
        self.theme = theme
    }
    
    func markCompleted(task: TestTask, score: Int) {
        persistenceController.saveCompletedTask(task: task.rawValue, score: score)
    }
    
    func fetchCompletedTasks() {
        completedTasks = persistenceController.fetchAllCompletedTasks()
    }
}

extension TestingModel {
    struct Phrase: Identifiable {
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
        TestingModel(title: "TestingModelSample", phrases: ["а", "та", "ла", "жах", "страх", "вибух", "а", "та", "ла", "жах", "страх", "вибух"], lengthInMinutes: 1, theme: .navy),
    ]
}
