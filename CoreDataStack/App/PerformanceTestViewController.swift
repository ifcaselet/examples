import UIKit
import Combine

final class PerformanceTestViewController: UIViewController {

    @IBOutlet private weak var executionButton: UIButton!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var statusLabel: UILabel!

    private let stack = CoreDataStack()

    private let maxItemsSaved: Int = 100_000

    override func viewDidLoad() {
        super.viewDidLoad()

        statusLabel.text = ""
    }

    @IBAction func executePerformanceTest() {
        activityIndicatorView.startAnimating()
        executionButton.isEnabled = false

        DispatchQueue.global().async {
            for index in 1...self.maxItemsSaved {

                self.stack.insertArticle(content: UUID().uuidString)

                DispatchQueue.main.async {
                    self.statusLabel.text = "Inserting \(index) of \(self.maxItemsSaved)"
                }
            }


            DispatchQueue.main.async {
                self.statusLabel.text = "Saving..."
            }


            self.stack.save {
                print("save completed")
                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
                    self.statusLabel.text = "Done"
                    self.executionButton.isEnabled = true
                }
            }
        }
    }
}
