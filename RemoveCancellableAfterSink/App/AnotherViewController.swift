import UIKit
import Combine

struct SingletonTimerProvider {
    static let timer = Timer.publish(every: 5, on: .main, in: .default).autoconnect()
}

final class AnotherViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple

        var cancellable: AnyCancellable?
        cancellable = SingletonTimerProvider.timer.sink { [weak self] value in
            print("received timer value: \(value)")

            // The if-clause is necessary to remove compiler warning that
            // the cancellable is not used.
            if cancellable != nil {
                cancellable = nil
            }

            guard let self = self else {
                return
            }

            self.dismiss(animated: true, completion: nil)
        }
    }

    deinit {
        print("deinit")
    }

}
