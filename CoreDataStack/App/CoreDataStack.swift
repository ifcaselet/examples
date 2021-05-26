import CoreData

final class CoreDataStack {

    private let persistentContainer = try! startPersistentContainer()

    private lazy var writerContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.viewContext
        return context
    }()

    private var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func save(_ completion: @escaping () -> ()) {
        writerContext.perform {
            self.writerContext.saveIfNeeded()

            self.viewContext.perform {
                let startTime = Date()

                self.viewContext.saveIfNeeded()

                let elapsed = Date().timeIntervalSince(startTime)
                print("time elapsed in main thread = \(elapsed)")

                completion()
            }
        }
    }
}

extension CoreDataStack {
    func insertArticle(content: String) {
        writerContext.perform {
            let obj = NSEntityDescription.insertNewObject(forEntityName: "Article", into: self.writerContext)
            obj.setValue(content, forKey: "content")
        }
    }
}

extension NSManagedObjectContext {
    func saveIfNeeded() {
        guard hasChanges else {
            return
        }

        try! save()
    }
}
