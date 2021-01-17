import XCTest
import CoreData
@testable import App

final class MigrationTests: XCTestCase {

    /// Unit test for migrating from V1 to V2.
    func testMigratingFromV1ToV2AddsTheAvailableForPurchaseProperty() throws {
        // Given
        let sourceContainer = try startPersistentContainer("App V1")

        let entityDescription = NSEntityDescription.entity(forEntityName: "BoardGame", in: sourceContainer.viewContext)!
        XCTAssertFalse(entityDescription.propertiesByName.keys.contains("availableForPurchase"))

        try sourceContainer.viewContext.save()

        // When
        let targetContainer = try migrate(container: sourceContainer, to: "App V2")

        let migratedEntityDescription =
            NSEntityDescription.entity(forEntityName: "BoardGame", in: targetContainer.viewContext)!
        XCTAssertTrue(migratedEntityDescription.propertiesByName.keys.contains("availableForPurchase"))
    }

    func testMigratingFromV1ToV2KeepsTheExistingData() throws {
        // Given
        let sourceContainer = try startPersistentContainer("App V1")

        insertBoardGame(name: "Chess", numberOfPlayers: 2, into: sourceContainer.viewContext)
        insertBoardGame(name: "Scrabble", numberOfPlayers: 4, into: sourceContainer.viewContext)

        try sourceContainer.viewContext.save()

        // When
        let targetContainer = try migrate(container: sourceContainer, to: "App V2")

        // Then
        // Prove the existing `BoardGame` data is still there.
        XCTAssertEqual(try countOfBoardGames(in: targetContainer.viewContext), 2)

        // And we can use the new availableForPurchase property
        let boardGame = insertBoardGame(name: "Monopoly", numberOfPlayers: 4, into: targetContainer.viewContext)
        boardGame.setValue(true, forKey: "availableForPurchase")

        XCTAssertNoThrow(try targetContainer.viewContext.save())
    }

    /// Unit test for the first model version.
    func testV1AddsTheBoardGameEntity() throws {
        // Given
        let container = try startPersistentContainer("App V1")

        // Confirm that we can interact with `container` and that there are no `BoardGames`
        // in the `NSManagedObjectContext`.
        XCTAssertEqual(try countOfBoardGames(in: container.viewContext), 0)

        // When
        insertBoardGame(name: "Chess", numberOfPlayers: 2, into: container.viewContext)

        // Then
        // Prove our expectations of V1 that it adds a useable `BoardGame` entity.
        XCTAssertEqual(try countOfBoardGames(in: container.viewContext), 1)
    }
}

private extension MigrationTests {
    @discardableResult
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
