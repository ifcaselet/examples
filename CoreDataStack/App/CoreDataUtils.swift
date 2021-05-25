import CoreData

private let momdURL = Bundle(for: ViewController.self).url(forResource: "App", withExtension: "momd")!
private let storeType = NSSQLiteStoreType

/// Create and load a store using the given model version. The store will be located in a
/// temporary directory.
///
/// - Returns: An `NSPersistentContainer` that is loaded and ready for usage.
func startPersistentContainer() throws -> NSPersistentContainer {
    let storeURL = makeTemporaryStoreURL()
    let model = NSManagedObjectModel(contentsOf: momdURL)!

    let container = makePersistentContainer(storeURL: storeURL,
                                            managedObjectModel: model)
    container.loadPersistentStores { _, error in
        fatalError(error?.localizedDescription ?? "")
    }

    return container
}

private func makePersistentContainer(storeURL: URL,
                                     managedObjectModel: NSManagedObjectModel) -> NSPersistentContainer {
    let description = NSPersistentStoreDescription(url: storeURL)
    description.shouldMigrateStoreAutomatically = false
    description.type = storeType

    let container = NSPersistentContainer(name: "App Container", managedObjectModel: managedObjectModel)
    container.persistentStoreDescriptions = [description]

    return container
}

private func storeURL(from container: NSPersistentContainer) -> URL {
    let description = container.persistentStoreDescriptions.first!
    return description.url!
}

private func makeTemporaryStoreURL() -> URL {
    URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent(UUID().uuidString)
        .appendingPathExtension("sqlite")
}
