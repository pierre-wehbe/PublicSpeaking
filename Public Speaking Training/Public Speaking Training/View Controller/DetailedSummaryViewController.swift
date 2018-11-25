import AVKit
import UIKit
import PDFKit

class DetailedSummaryViewController: UIViewController {

    @IBOutlet weak var pdfViewContainer: UIView!
    private var pdfView: PDFView!
    public var currentInstance: PresentationInstance!

    @IBOutlet weak var currentPageTranscipt: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        addTap()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentInstance.currentPage = 0 // initializes to page 0
        currentPageTranscipt.text = currentInstance.getTranscript()
        if pdfView != nil {
            pdfView.removeFromSuperview()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpPreviewView()
    }

    @IBAction func playAudio(_ sender: Any) {
        currentInstance.playAudioFile()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTranscriptViewFromDetail" {
            (segue.destination as! TranscriptViewController).currentInstance = currentInstance
            (segue.destination as! TranscriptViewController).fromDetailedSummary = true
        }
    }

    @IBAction func unwindToDetailedSummary(segue:UIStoryboardSegue) {
    }

    private func setUpPreviewView() {
        pdfView = PDFView(frame: pdfViewContainer.frame)
        pdfView.center = pdfViewContainer.center
        pdfView.document = currentInstance.pdfDocument
        pdfView.displayDirection = .horizontal
        pdfView.displayMode = .singlePage
        pdfView.autoScales = true
        view.addSubview(pdfView) //FIXME: Will have multple subviews
    }

    private func addTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if let yTouchPos = sender?.location(in: view).y {
            if yTouchPos < pdfViewContainer.frame.minY
                || yTouchPos > pdfViewContainer.frame.maxY {
                return
            }
        } else {
            return
        }

        if let xTouchPos = sender?.location(in: view).x {
            if xTouchPos > pdfViewContainer.center.x {
                if pdfView.canGoToNextPage() {
                    pdfView.goToNextPage(sender)
                    currentInstance.incrementPage()
                    currentPageTranscipt.text = currentInstance.getTranscript()
                }
            } else {
                if pdfView.canGoBack() {
                    pdfView.goToPreviousPage(sender)
                    currentInstance.decrementPage()
                    currentPageTranscipt.text = currentInstance.getTranscript()
                }
            }
        }
    }
}
