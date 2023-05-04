//
//  PersistenceController.swift
//  Year Work
//
//  Created by Bohdan Arkhypchuk on 02.05.2023.
//

import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TestingResultsDataModel")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }

    func saveCompletedTask(task: String, score: Int, transcribedPhrases: [String]? = []) {
        let completedTask = CompletedTask(context: container.viewContext)
        completedTask.task = task
        completedTask.score = Double(score)
        completedTask.transcribedPhrases = transcribedPhrases

        do {
            try container.viewContext.save()
        } catch {
            print("Failed to save completed task: \(error)")
        }
    }

    func fetchAllCompletedTasks() -> [CompletedTask] {
        let fetchRequest: NSFetchRequest<CompletedTask> = CompletedTask.fetchRequest()

        do {
            return try container.viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch completed tasks: \(error)")
            return []
        }
    }
    
    func deleteAllCompletedTasks() {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CompletedTask.fetchRequest()
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try container.viewContext.execute(batchDeleteRequest)
                try container.viewContext.save()
            } catch {
                print("Failed to delete all completed tasks: \(error)")
            }
        }
}

