import CoreData
import XCTest

@testable import App

private let mainBundle = Bundle(for: ViewController.self)
private let momdURL = mainBundle.url(forResource: "App", withExtension: "momd")!
private let storeType = NSSQLiteStoreType

/// Load an `NSPersistentContainer` using the given `storeURL`
/// and `NSManagedObjectModel`.
func loadPersistentContainer(storeURL: URL,
                             model: NSManagedObjectModel) -> NSPersistentContainer {
    let container = makePersistentContainer(storeURL: storeURL,
                                            managedObjectModel: model)
    container.loadPersistentStores { _, error in
        XCTAssertNil(error)
    }

    return container
}

/// Migrates the store located at `storeURL`.
///
/// - Parameter storeURL: The URL of the Core Data store that will be migrated.
/// - Parameter from: The current model version of `storeURL`.
/// - Parameter to: The model version to migrate to.
func migrate(storeURL: URL,
             from sourceModel: NSManagedObjectModel,
             to destinationModel: NSManagedObjectModel) throws {
    // Create a temporary store URL. This is where the migrated data
    // using the model will be located.
    let tempMigratedStoreURL = makeTemporaryStoreURL()

    // Retrieve the custom mapping model that we defined.
    let mappingModel = NSMappingModel(from: [mainBundle],
                                      forSourceModel: sourceModel,
                                      destinationModel: destinationModel)!

    let migrationManager = NSMigrationManager(sourceModel: sourceModel,
                                              destinationModel: destinationModel)
    // Migrate the `sourceStoreURL` to `tempMigratedStoreURL`.
    try migrationManager.migrateStore(from: storeURL,
                                      sourceType: storeType,
                                      options: nil,
                                      with: mappingModel,
                                      toDestinationURL: tempMigratedStoreURL,
                                      destinationType: storeType,
                                      destinationOptions: nil)

    // Copy the `tempMigratedStoreURL` to the `sourceStoreURL` to
    // complete the migration.
    try NSPersistentStoreCoordinator().replacePersistentStore(
        at: storeURL,
        destinationOptions: nil,
        withPersistentStoreFrom: tempMigratedStoreURL,
        sourceOptions: nil,
        ofType: storeType)
}

func managedObjectModel(versionName: String) -> NSManagedObjectModel {
    let url = momdURL.appendingPathComponent(versionName).appendingPathExtension("mom")
    return NSManagedObjectModel(contentsOf: url)!
}

func makeTemporaryStoreURL() -> URL {
    URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent(UUID().uuidString)
        .appendingPathExtension("sqlite")
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

private func storeURL(from container: NSPersistentContainer) -> URL {
    let description = container.persistentStoreDescriptions.first!
    return description.url!
}
