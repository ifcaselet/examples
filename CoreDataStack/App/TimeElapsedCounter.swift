import UIKit
import Combine

/// Counts up and updates a label for how many seconds have elapsed since
/// this was started.
final class TimeElapsedCounter {

    private let label: UILabel
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common)
    private var cancellables = Set<AnyCancellable>()

    private var startDate = Date()

    init(_ label: UILabel) {
        self.label = label
    }

    func start() {
        startDate = Date()

        timer.sink { [weak self] currentDate in
            guard let self = self else { return }

            let interval = currentDate.timeIntervalSince(self.startDate)
            self.label.text = String(format: "Seconds elapsed: %.6f", interval)
        }.store(in: &cancellables)

        timer.connect().store(in: &cancellables)
    }

    func stop() {
        cancellables.forEach { $0.cancel() }
    }
}
