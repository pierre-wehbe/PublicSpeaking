import UIKit
import PDFKit

class DetailedSummaryViewController: UIViewController {

    @IBOutlet weak var pdfViewContainer: UIView!
    private var pdfView: PDFView!
    public var currentInstance: PresentationInstance!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTap()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpPreviewView()
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
                }
            } else {
                if pdfView.canGoBack() {
                    pdfView.goToPreviousPage(sender)
                }
            }
        }
    }
    

}
