import CoreData

final class ConcurrentCoreDataStack: CoreDataStack {
    private let persistentContainer = try! startPersistentContainer()

    private var parentContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private(set) lazy var writerContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.name = "WriterContext"
        return context
    }()

    func save(_ completion: @escaping () -> ()) {
        #warning("TODO")
    }
}
