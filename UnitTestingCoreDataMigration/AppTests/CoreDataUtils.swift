import CoreData
import XCTest

@testable import App

private let momdURL = Bundle(for: ViewController.self).url(forResource: "App", withExtension: "momd")!
private let storeType = NSSQLiteStoreType

/// Create and load a store using the given model version. The store will be located in a
/// temporary directory.
///
/// - Parameter versionName: The name of the model (`.xcdatamodel`). For example, `"App V1"`.
/// - Returns: An `NSPersistentContainer` that is loaded and ready for usage.
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

/// Migrates the given `container` to a new store URL. The new (migrated) store will be located
/// in a temporary directory.
///
/// - Parameter container: The `NSPersistentContainer` containing the source store that will be
///                        migrated.
/// - Parameter versionName: The name of the model (`.xcdatamodel`) to migrate to. For example,
///                          `"App V2"`.
///
/// - Returns: A migrated `NSPersistentContainer` that is loaded and ready for usage. This
///            container uses a different store URL than the original `container`.
func migrate(container: NSPersistentContainer, to versionName: String) throws -> NSPersistentContainer {
    // Define the source and destination `NSManagedObjectModels`.
    let sourceModel = container.managedObjectModel
    let destinationModel = managedObjectModel(versionName: versionName)

    let sourceStoreURL = storeURL(from: container)
    // Create a new temporary store URL. This is where the migrated data using the model
    // will be located.
    let destinationStoreURL = makeTemporaryStoreURL()

    // Infer a mapping model between the source and destination `NSManagedObjectModels`.
    // Modify this line if you use a custom mapping model.
    let mappingModel = try NSMappingModel.inferredMappingModel(forSourceModel: sourceModel,
                                                               destinationModel: destinationModel)

    let migrationManager = NSMigrationManager(sourceModel: sourceModel,
                                              destinationModel: destinationModel)
    // Migrate the `sourceStoreURL` to `destinationStoreURL`.
    try migrationManager.migrateStore(from: sourceStoreURL,
                                      sourceType: storeType,
                                      options: nil,
                                      with: mappingModel,
                                      toDestinationURL: destinationStoreURL,
                                      destinationType: storeType,
                                      destinationOptions: nil)

    // Load the store at `destinationStoreURL` and return the container.
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
    // In order to have more control over when the migration happens, we're setting
    // `shouldMigrateStoreAutomatically` to `false` to stop `NSPersistentContainer`
    // from **automatically** migrating the store. Leaving this as `true` might result in false positives.
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
