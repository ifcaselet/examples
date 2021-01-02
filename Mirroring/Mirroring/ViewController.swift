
import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var numberOfPlayersLabel: UILabel!
    @IBOutlet private weak var purchaseButton: UIButton!

    private let boardGame: BoardGame

    init(boardGame: BoardGame) {
        self.boardGame = boardGame
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = boardGame.name
        numberOfPlayersLabel.text = "Up to \(boardGame.numberOfPlayers) players."
        purchaseButton.isHidden = !boardGame.availableForPurchase
    }
}
