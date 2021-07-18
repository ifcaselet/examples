import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBSegueAction private func makeNestedPerformanceViewController(_ coder: NSCoder) -> PerformanceTestViewController? {
        PerformanceTestViewController(coder, stack: NestedCoreDataStack())
    }

    @IBSegueAction private func makeConcurrentPerformanceViewController(_ coder: NSCoder) -> PerformanceTestViewController? {
        PerformanceTestViewController(coder, stack: ConcurrentCoreDataStack())
    }
}

