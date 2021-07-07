import CoreData

final class NestedCoreDataStack: CoreDataStack {
    private let persistentContainer = try! startPersistentContainer()

    private var parentContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private(set) lazy var writerContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.parentContext
        return context
    }()

    func save(_ completion: @escaping () -> ()) {
        writerContext.perform {
            self.writerContext.saveIfNeeded()

            self.parentContext.perform {
                let startTime = Date()

                self.parentContext.saveIfNeeded()

                let elapsed = Date().timeIntervalSince(startTime)
                print("time elapsed in main thread = \(elapsed)")

                completion()
            }
        }
    }
}
