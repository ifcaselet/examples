import UIKit

final class PerformanceTestViewController: UIViewController {

    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var statusLabel: UILabel!

    private let stack = CoreDataStack()

    override func viewDidLoad() {
        super.viewDidLoad()

        statusLabel.text = ""
    }

    @IBAction func executePerformanceTest() {

    }
}
