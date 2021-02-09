import CoreData
import XCTest

@testable import App

private let mainBundle = Bundle(for: ViewController.self)
private let momdURL = mainBundle.url(forResource: "App", withExtension: "momd")!
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

/// Migrates the given `container` to a new model version.
///
/// - Parameter container: The `NSPersistentContainer` containing the source store that will be
///                        migrated. This will no longer be useable after the migration.
/// - Parameter versionName: The name of the model (`.xcdatamodel`) to migrate to. For example,
///                          `"App V2"`.
///
/// - Returns: A migrated `NSPersistentContainer` that is loaded and ready for usage.
func migrate(container: NSPersistentContainer, to versionName: String) throws -> NSPersistentContainer {
    // Define the source and destination `NSManagedObjectModels`.
    let sourceModel = container.managedObjectModel
    let destinationModel = managedObjectModel(versionName: versionName)

    let sourceStoreURL = storeURL(from: container)
    // Create a temporary store URL. This is where the migrated data using the model
    // will be located.
    let tempMigratedStoreURL = makeTemporaryStoreURL()

    // Retrieve the custom mapping model.
    let mappingModel = NSMappingModel(from: [mainBundle],
                                      forSourceModel: sourceModel,
                                      destinationModel: destinationModel)!

    let migrationManager = NSMigrationManager(sourceModel: sourceModel,
                                              destinationModel: destinationModel)
    // Migrate the `sourceStoreURL` to `destinationStoreURL`.
    try migrationManager.migrateStore(from: sourceStoreURL,
                                      sourceType: storeType,
                                      options: nil,
                                      with: mappingModel,
                                      toDestinationURL: tempMigratedStoreURL,
                                      destinationType: storeType,
                                      destinationOptions: nil)

    // Replace the sourceStoreURL with the migrated destinationStoreURL to complete the migration.
    try container.persistentStoreCoordinator.replacePersistentStore(
        at: sourceStoreURL,
        destinationOptions: nil,
        withPersistentStoreFrom: tempMigratedStoreURL,
        sourceOptions: nil,
        ofType: storeType)

    // Create a new migrated container to load the store at `sourceStoreURL`
    // using the new `destinationModel`.
    let migratedContainer = makePersistentContainer(storeURL: sourceStoreURL,
                                                    managedObjectModel: destinationModel)
    migratedContainer.loadPersistentStores { _, error in
        XCTAssertNil(error)
    }

    return migratedContainer
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
