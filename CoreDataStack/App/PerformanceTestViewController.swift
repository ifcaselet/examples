import UIKit
import Combine

final class PerformanceTestViewController: UIViewController {

    @IBOutlet private weak var executionButton: UIButton!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var timeElapsedLabel: UILabel!
    @IBOutlet private weak var numberOfObjectsSavedLabel: UILabel!

    private let stack: CoreDataStack

    private lazy var secondsCounter = TimeElapsedCounter(timeElapsedLabel)
    private let maxItemsSaved: Int = 25_000

    init?(_ coder: NSCoder, stack: CoreDataStack) {
        self.stack = stack

        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

private func longString() -> String {
    var string = ""
    for _ in 1..<Int.random(in: 100...900) {
        string.append(UUID().uuidString)
    }

    return string
}
