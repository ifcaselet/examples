import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let button = UIButton(frame: .init(x: 20, y: 100, width: 200, height: 44))
        button.setTitle("Click Me", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
        view.addSubview(button)
    }

    @objc func buttonTapped(sender: UIButton) {
        let viewController = AnotherViewController()
        let navigationViewController = UINavigationController(rootViewController: viewController)
        show(navigationViewController, sender: self)
    }

}

