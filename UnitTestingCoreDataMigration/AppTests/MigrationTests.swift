import XCTest
import CoreData
@testable import App

final class MigrationTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testV1AddsTheBoardGameEntity() throws {
        // Given
        let container = try startPersistentContainer("App V1")

        // Confirm that we can interact with `container` and that there are no `BoardGames`
        // in the `NSManagedObjectContext`.
        XCTAssertEqual(try countOfBoardGames(in: container.viewContext), 0)

        // When
        _ = insertBoardGame(name: "Chess", numberOfPlayers: 2, into: container.viewContext)

        // Then
        // Prove our expectations of V1 that it adds a useable `BoardGame` entity.
        XCTAssertEqual(try countOfBoardGames(in: container.viewContext), 1)
    }
}

private extension MigrationTests {
    func insertBoardGame(name: String, numberOfPlayers: Int, into context: NSManagedObjectContext) -> NSManagedObject {
        let obj = NSEntityDescription.insertNewObject(forEntityName: "BoardGame", into: context)
        obj.setValue(name, forKey: "name")
        obj.setValue(numberOfPlayers, forKey: "numberOfPlayers")
        return obj
    }

    func countOfBoardGames(in context: NSManagedObjectContext) throws -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BoardGame")
        fetchRequest.includesSubentities = false
        fetchRequest.resultType = .countResultType

        return try context.count(for: fetchRequest)
    }
}
