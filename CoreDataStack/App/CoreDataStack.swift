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
        writerContext.performAndWait {
            writerContext.saveIfNeeded()

            viewContext.performAndWait {
                viewContext.saveIfNeeded()
            }
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
