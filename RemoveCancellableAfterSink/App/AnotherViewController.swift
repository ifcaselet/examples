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
        cancellable = SingletonTimerProvider.timer.sink { value in
            print("received timer value: \(value)")

            self.dismiss(animated: true, completion: nil)

            // The if-clause is necessary to remove compiler warning that
            // the cancellable is not used.
            if cancellable != nil {
                cancellable = nil
            }
        }
    }

    deinit {
        print("deinit")
    }

}
