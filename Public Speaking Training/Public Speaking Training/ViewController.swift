import AVKit
import PDFKit
import UIKit

class ViewController: UIViewController {
    
    public var fileLocalPath: String!
    public var data: Data? = nil
    public var pdfView: PDFView!
    
    public var currentInstance: PresentationInstance!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBAction func donePresenting(_ sender: Any) {
        currentInstance.stopAll()
    }
    
    
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
        let file = PresentationFile()
        currentInstance = file.createInstance()
        pdfView.document = currentInstance.pdfDocument
        pdfView.displayDirection = .horizontal
        pdfView.displayMode = .singlePage
        pdfView.autoScales = true
        view.addSubview(pdfView)
        view.bringSubviewToFront(doneButton)
        currentInstance.delegate = self
        currentInstance.startRecording()
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
                    currentInstance.goToNextPage()
                }
            } else {
                if pdfView.canGoBack() {
                    pdfView.goToPreviousPage(sender)
                    currentInstance.goToPreviousPage()
                }
            }
        }
        
    }
}

extension ViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        let path = recorder.url
        print(path)
    }
}
