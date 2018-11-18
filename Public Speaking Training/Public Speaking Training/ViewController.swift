import PDFKit
import UIKit

class ViewController: UIViewController {

    public var fileLocalPath: String!
    public var data: Data? = nil
    public var pdfView: PDFView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTap()
        setUpView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setUpView() {
        pdfView = PDFView(frame: view.frame)
        pdfView.center = view.center
        let path = Bundle.main.path(forResource: "test", ofType: "pdf")
        let url = URL(fileURLWithPath: path!)
        let pdfDocument = PDFDocument(url: url)
        pdfView.document = pdfDocument
        pdfView.displayDirection = .horizontal
        pdfView.displayMode = .singlePage
        pdfView.autoScales = true
        view.addSubview(pdfView)
    }
    
    private func addTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if let xTouchPos = sender?.location(in: view).x {
            if xTouchPos > view.center.x {
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

