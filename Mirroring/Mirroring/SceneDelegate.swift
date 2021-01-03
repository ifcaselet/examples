
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Use dummy BoardGame
        let chess = BoardGame(name: "Chess", numberOfPlayers: 2, availableForPurchase: true)
        let viewController = BoardGameViewController(boardGame: chess)

        let navigationController = UINavigationController(rootViewController: viewController)

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController

        window?.makeKeyAndVisible()
    }
}

