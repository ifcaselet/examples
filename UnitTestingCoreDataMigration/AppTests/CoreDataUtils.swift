import CoreData
import XCTest

@testable import App

private let momdURL = Bundle(for: ViewController.self).url(forResource: "App", withExtension: "momd")!
private let storeType = NSSQLiteStoreType

func startPersistentContainer(_ versionName: String) throws -> NSPersistentContainer {
    let storeURL = makeTemporaryStoreURL()
    let model = managedObjectModel(versionName: versionName)

    let container = makePersistentContainer(storeURL: storeURL,
                                            managedObjectModel: model)
    container.loadPersistentStores { _, error in
        XCTAssertNil(error)
    }

    return container
}

func migrate(container: NSPersistentContainer, to versionName: String) throws -> NSPersistentContainer {
    let sourceModel = container.managedObjectModel
    let destinationModel = managedObjectModel(versionName: versionName)

    let sourceStoreURL = storeURL(from: container)
    let destinationStoreURL = makeTemporaryStoreURL()

    let mappingModel = try NSMappingModel.inferredMappingModel(forSourceModel: sourceModel,
                                                               destinationModel: destinationModel)

    let migrationManager = NSMigrationManager(sourceModel: sourceModel,
                                              destinationModel: destinationModel)
    try migrationManager.migrateStore(from: sourceStoreURL,
                                      sourceType: storeType,
                                      options: nil,
                                      with: mappingModel,
                                      toDestinationURL: destinationStoreURL,
                                      destinationType: storeType,
                                      destinationOptions: nil)

    let destinationContainer = makePersistentContainer(storeURL: destinationStoreURL,
                                                       managedObjectModel: destinationModel)
    destinationContainer.loadPersistentStores { _, error in
        XCTAssertNil(error)
    }

    return destinationContainer
}

private func makePersistentContainer(storeURL: URL,
                             managedObjectModel: NSManagedObjectModel) -> NSPersistentContainer {
    let description = NSPersistentStoreDescription(url: storeURL)
    // Do not automatically migrate because we will be manually migrating (and testing) the store.
    description.shouldMigrateStoreAutomatically = false
    description.type = storeType

    let container = NSPersistentContainer(name: "App Container", managedObjectModel: managedObjectModel)
    container.persistentStoreDescriptions = [description]

    return container
}

private func managedObjectModel(versionName: String) -> NSManagedObjectModel {
    let url = momdURL.appendingPathComponent(versionName).appendingPathExtension("mom")
    return NSManagedObjectModel(contentsOf: url)!
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
