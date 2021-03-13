import UIKit
import Combine

struct SingletonTimerProvider {
    static let timer = Timer.publish(every: 5, on: .main, in: .default).autoconnect()
}

final class AnotherViewController: UIViewController {

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple

        SingletonTimerProvider.timer.sink { value in
            self.dismiss(animated: true, completion: nil)
        }.store(in: &cancellables)
    }

    deinit {
        print("deinit")
    }

}
