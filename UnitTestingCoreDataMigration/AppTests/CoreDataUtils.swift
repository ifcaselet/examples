import CoreData
import XCTest

@testable import App

private let momdURL = Bundle(for: ViewController.self).url(forResource: "App", withExtension: "momd")!

func startPersistentContainer(_ versionName: String) throws -> NSPersistentContainer {
    let storeURL = makeTemporaryStoreURL()
    let model = managedObjectModel(versionName: versionName)

    let container = makePersistentContainer(storeURL: storeURL, managedObjectModel: model)
    container.loadPersistentStores { _, error in
        XCTAssertNil(error)
    }

    return container
}

private func makePersistentContainer(storeURL: URL,
                             managedObjectModel: NSManagedObjectModel) -> NSPersistentContainer {
    let description = NSPersistentStoreDescription(url: storeURL)
    // Do not automatically migrate because we will be manually migrating (and testing) the store.
    description.shouldMigrateStoreAutomatically = false
    description.type = NSSQLiteStoreType

    let container = NSPersistentContainer(name: "App Container", managedObjectModel: managedObjectModel)
    container.persistentStoreDescriptions = [description]

    return container
}

private func managedObjectModel(versionName: String) -> NSManagedObjectModel {
    let url = momdURL.appendingPathComponent(versionName).appendingPathExtension("mom")
    return NSManagedObjectModel(contentsOf: url)!
}

private func makeTemporaryStoreURL() -> URL {
    URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent(UUID().uuidString)
        .appendingPathExtension("sqlite")
}
