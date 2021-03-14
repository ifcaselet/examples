import UIKit
import Combine

struct SingletonTimerProvider {
    static let timer = Timer.publish(every: 3, on: .main, in: .default).autoconnect()
}

final class AnotherViewController: UIViewController {

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple

        var cancellable: AnyCancellable?
        cancellable = SingletonTimerProvider.timer.sink { [weak self, weak cancellable] value in
            print("received timer value: \(value)")

            guard let self = self else {
                return
            }

            if let cancellable = cancellable {
                self.cancellables.remove(cancellable)
            }

            self.dismiss(animated: true, completion: nil)
        }

        cancellables.insert(cancellable!)
    }

    deinit {
        print("deinit")
    }

}
