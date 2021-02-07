import XCTest
import CoreData
@testable import App

final class MigrationTests: XCTestCase {

    func testMigratingFromV1ToV2DeletesThePosts() throws {
        // Given
        let sourceContainer = try startPersistentContainer("App V1")

        let post = insertPost(title: "Alpha", into: sourceContainer.viewContext)
        insertComment(message: "a comment", post: post, into: sourceContainer.viewContext)

        try sourceContainer.viewContext.save()

        // When
        let targetContainer = try migrate(container: sourceContainer, to: "App V2")

        // Then
        XCTAssertEqual(try countOfPosts(in: targetContainer.viewContext), 1)
        XCTAssertEqual(try countOfComments(in: targetContainer.viewContext), 1)
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

    func countOfComments(in context: NSManagedObjectContext) throws -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Comment")
        fetchRequest.includesSubentities = false
        fetchRequest.resultType = .countResultType

        return try context.count(for: fetchRequest)
    }
}
