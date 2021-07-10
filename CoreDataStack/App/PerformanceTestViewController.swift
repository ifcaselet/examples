import UIKit
import Combine

final class PerformanceTestViewController: UIViewController {

    @IBOutlet private weak var executionButton: UIButton!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var timeElapsedLabel: UILabel!
    @IBOutlet private weak var numberOfObjectsSavedLabel: UILabel!

    private let stack = NestedCoreDataStack()
    private lazy var secondsCounter = TimeElapsedCounter(timeElapsedLabel)

    private let maxItemsSaved: Int = 25_000

    override func viewDidLoad() {
        super.viewDidLoad()

        statusLabel.text = ""
        timeElapsedLabel.text = ""
        numberOfObjectsSavedLabel.text = ""
    }

    @IBAction func executePerformanceTest() {
        activityIndicatorView.startAnimating()
        executionButton.isEnabled = false
        timeElapsedLabel.text = ""
        numberOfObjectsSavedLabel.text = ""

        DispatchQueue.global().async {
            for index in 1...self.maxItemsSaved {

                self.stack.insertArticle(content: longString())

                DispatchQueue.main.async {
                    self.statusLabel.text = "Inserting \(index) of \(self.maxItemsSaved)"
                }
            }

            DispatchQueue.main.async {
                self.secondsCounter.start()
                self.statusLabel.text = "Saving..."
            }

            self.stack.save {
                DispatchQueue.main.async {
                    self.secondsCounter.stop()
                    self.activityIndicatorView.stopAnimating()
                    self.statusLabel.text = "Done"
                    self.executionButton.isEnabled = true

                    self.stack.fetchArticlesCount { count in
                        self.numberOfObjectsSavedLabel.text = "\(count) objects saved"
                    }

                    self.stack.fetchFirstFewArticles { content in
                        print("Some of the objects saved: \(content)")
                    }
                }
            }
        }
    }
}

/// Counts up and updates a label for how many seconds have elapsed since
/// this was started.
private class TimeElapsedCounter {

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

private func longString() -> String {
    var string = ""
    for _ in 1..<Int.random(in: 100...900) {
        string.append(UUID().uuidString)
    }

    return string
}
