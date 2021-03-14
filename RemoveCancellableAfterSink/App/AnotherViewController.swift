import UIKit
import Combine

struct SingletonTimerProvider {
    static let timer = Timer.publish(every: 2, on: .main, in: .default).autoconnect()
}

final class AnotherViewController: UIViewController {

    private var cancellables = Set<AnyCancellable>()
    private let startingTimeInterval = Date().timeIntervalSince1970
    private let maxThreshold = 10.0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple

        subscribeToTimer(threshold: 3.0)
    }

    private func subscribeToTimer(threshold: TimeInterval) {
        var cancellable: AnyCancellable?
        cancellable = SingletonTimerProvider.timer.sink { [weak self] value in
            print("Received timer value: \(value)")
            guard let self = self else {
                return
            }

            print("Subscriptions = \(self.cancellables.count)")

            let threshold = min(threshold, self.maxThreshold)
            if threshold == self.maxThreshold {
                print("Max threshold reached. There should be no active subscriptions after this.")
            }

            if value.timeIntervalSince1970 - self.startingTimeInterval < min(threshold, self.maxThreshold) {
                print("Recursively subscribing to timer")
                self.subscribeToTimer(threshold: threshold + 3.0)
            } else {
                if let cancellable = cancellable {
                    self.cancellables.remove(cancellable)
                }
            }
        }

        cancellables.insert(cancellable!)
    }

    deinit {
        print("deinit")
    }
}
