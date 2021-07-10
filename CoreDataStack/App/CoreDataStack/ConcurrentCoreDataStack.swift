import CoreData

final class ConcurrentCoreDataStack: CoreDataStack {
    private let persistentContainer = try! startPersistentContainer()

    var readerContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private(set) lazy var writerContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.name = "WriterContext"
        return context
    }()

    func save(_ completion: @escaping () -> ()) {
        writerContext.perform {
            self.writerContext.saveIfNeeded()
            completion()
        }
    }
}
