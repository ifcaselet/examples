import XCTest
import CoreData
@testable import App

final class MigrationTests: XCTestCase {
    /// Tests that when migrating from V1 to V2, the `Post` objects are deleted.
    func testMigratingFromV1ToV2DeletesThePosts() throws {
        // Given
        let storeURL = makeTemporaryStoreURL()
        let v1Model = managedObjectModel(versionName: "App V1")

        // Add test data for the App V1 store.
        let container = loadPersistentContainer(storeURL: storeURL,
                                                model: v1Model)

        let post = insertPost(title: "Alpha", into: container.viewContext)
        insertComment(message: "a comment", post: post, into: container.viewContext)

        try container.viewContext.save()

        // Pre-condition check
        XCTAssertEqual(try countOfPosts(in: container.viewContext), 1)
        XCTAssertEqual(try countOfComments(in: container.viewContext), 1)

        // When
        let v2Model = managedObjectModel(versionName: "App V2")

        try migrate(storeURL: storeURL, from: v1Model, to: v2Model)

        // Then
        // Load a new NSPersistentContainer because the old one will be
        // unuseable after the migration.
        let migratedContainer = loadPersistentContainer(storeURL: storeURL,
                                                        model: v2Model)

        // The Post should have been deleted because of the
        // DeleteObjectsMigrationPolicy defined in the PostToPost entity mapping.
        XCTAssertEqual(try countOfPosts(in: migratedContainer.viewContext), 0)
        // The Comment is left intact.
        XCTAssertEqual(try countOfComments(in: migratedContainer.viewContext), 1)
    }
}

private extension MigrationTests {
    /// Insert a `Post` object into the given `context`.
    @discardableResult
    func insertPost(title: String, into context: NSManagedObjectContext) -> NSManagedObject {
        let obj = NSEntityDescription.insertNewObject(forEntityName: "Post", into: context)
        obj.setValue(title, forKey: "title")
        return obj
    }

    /// Insert a `Comment` object into the given `context`.
    @discardableResult
    func insertComment(message: String, post: NSManagedObject, into context: NSManagedObjectContext) -> NSManagedObject {
        let obj = NSEntityDescription.insertNewObject(forEntityName: "Comment", into: context)
        obj.setValue(message, forKey: "message")
        obj.setValue(post, forKey: "post")
        return obj
    }

    /// Return the total number of `Post` objects inside the given `context`.
    func countOfPosts(in context: NSManagedObjectContext) throws -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Post")
        fetchRequest.includesSubentities = false
        fetchRequest.resultType = .countResultType

        return try context.count(for: fetchRequest)
    }

    /// Return the total number of `Comment` objects inside the given `context`.
    func countOfComments(in context: NSManagedObjectContext) throws -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Comment")
        fetchRequest.includesSubentities = false
        fetchRequest.resultType = .countResultType

        return try context.count(for: fetchRequest)
    }
}
