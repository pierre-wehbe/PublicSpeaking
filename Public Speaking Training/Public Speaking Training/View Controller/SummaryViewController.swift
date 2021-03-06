import UIKit
import UICircularProgressRing

class SummaryViewController: UIViewController {

    @IBOutlet weak var performanceBar: UICircularProgressRing!
    var currentInstance: PresentationInstance!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPerformanceBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performanceBar.startProgress(to: 80, duration: 2.0) {
            print("Done animating!")
        }
        print("Average Rate: \(currentInstance.getTotalAverageWordsPerMin())")
    }
    
    private func setUpPerformanceBar() {
        performanceBar.maxValue = 100
        performanceBar.innerRingColor = getSecondaryColor()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToInstanceViewer" {
            (segue.destination as! PresentationFileViewController).presentationFile.saveCurrentInstance()
            (segue.destination as! PresentationFileViewController).instancesTableView.reloadData()
        } else if segue.identifier == "toTranscriptView" {
            (segue.destination as! TranscriptViewController).currentInstance = currentInstance
            (segue.destination as! TranscriptViewController).fromDetailedSummary = false
        }
    }

    @IBAction func unwindToSummary(segue:UIStoryboardSegue) {
    }

}
