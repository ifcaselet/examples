import CoreData

final class CoreDataStack {

    private let persistentContainer = try! startPersistentContainer()

    private lazy var writerContext: NSManagedObjectContext = {
        let context = self.persistentContainer.newBackgroundContext()
        context.parent = self.viewContext
        return context
    }()

    private var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func save() {
        writerContext.perform {
            self.writerContext.saveIfNeeded()

            self.viewContext.perform {
                self.viewContext.saveIfNeeded()
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
