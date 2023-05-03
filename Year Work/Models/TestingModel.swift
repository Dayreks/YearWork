import UIKit

class TestingModel: Identifiable {
    
    let persistenceController = PersistenceController.shared
    
    var title: String
    
    @Published var completedTasks: [CompletedTask] = PersistenceController.shared.fetchAllCompletedTasks()
    

    var theme: Theme
    
    init(title: String, theme: Theme) {
        self.title = title
        self.theme = theme
    }
    
    func markCompleted(task: TestTask, score: Int, transcribedPhrases: [String]?) {
        completedTasks = persistenceController.fetchAllCompletedTasks()
        if !completedTasks.contains(where: { $0.task == task.rawValue }) {
            persistenceController.saveCompletedTask(task: task.rawValue, score: score, transcribedPhrases: transcribedPhrases)
        }
    }
    
    func fetchCompletedTasks() {
        completedTasks = persistenceController.fetchAllCompletedTasks()
    }
}

extension TestingModel {
    static let sampleData: [TestingModel] =
    [
        TestingModel(title: "TestingModelSample", theme: .navy),
    ]
}
