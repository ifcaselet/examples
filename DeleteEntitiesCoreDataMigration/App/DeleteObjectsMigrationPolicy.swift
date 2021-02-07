import CoreData

final class DeleteObjectsMigrationPolicy: NSEntityMigrationPolicy {
    override func createDestinationInstances(forSource sInstance: NSManagedObject,
                                             in mapping: NSEntityMapping,
                                             manager: NSMigrationManager) throws {

    }
}
