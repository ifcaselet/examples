import XCTest
import CoreData
@testable import App

final class MigrationTests: XCTestCase {

    /// Tests that when migrating from V1 to V2, the `Post` objects are deleted.
    func testMigratingFromV1ToV2DeletesThePosts() throws {
        // Given
        let container = try startPersistentContainer("App V1")

        let post = insertPost(title: "Alpha", into: container.viewContext)
        insertComment(message: "a comment", post: post, into: container.viewContext)

        try container.viewContext.save()

        // When
        let migratedContainer = try migrate(container: container, to: "App V2")

        // Then
        // The post should have been deleted.
        XCTAssertEqual(try countOfPosts(in: migratedContainer.viewContext), 0)
        // The comment is left intact.
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
