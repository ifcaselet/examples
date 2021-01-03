
import XCTest
@testable import Mirroring

class BoardGameViewControllerTests: XCTestCase {

    /// Test that the **private** `purchaseButton` is hidden if the `BoardGame` cannot be purchased.
    ///
    func testExample() throws {
        let monopoly = BoardGame(name: "Monopoly",
                                 numberOfPlayers: 1_532,
                                 availableForPurchase: false)

        // Load the view to test.
        let viewController = BoardGameViewController(boardGame: monopoly)
        viewController.loadViewIfNeeded()

        // Grab the private `purchaseButton` using Mirror.
        let mirror = Mirror(reflecting: viewController)
        let purchaseButton = mirror.descendant("purchaseButton") as! UIButton

        // We can now test the `purchaseButton` normally.
        XCTAssertTrue(purchaseButton.isHidden)
    }
}
