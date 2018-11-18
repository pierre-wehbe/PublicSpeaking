import AVKit
import PDFKit
import UIKit
import googleapis

class ViewController: UIViewController {
    
    private let SAMPLE_RATE = 16000
    
    public var fileLocalPath: String!
    public var data: Data? = nil
    public var pdfView: PDFView!
    
    public var currentInstance: PresentationInstance!
    
    var audioData: NSMutableData!
    
    @IBOutlet weak var doneButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        AudioController.sharedInstance.delegate = self
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
        startRecording()
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
    
    //MARK: Button Actions
    @IBAction func donePresenting(_ sender: Any) {
        _ = AudioController.sharedInstance.stop()
        SpeechRecognitionService.sharedInstance.stopStreaming()
        currentInstance.stopAll()
    }
}

extension ViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        let path = recorder.url
        print(path)
    }
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record, mode: .default)
        } catch {
            print("Coudn't start recording")
        }
        audioData = NSMutableData()
        _ = AudioController.sharedInstance.prepare(specifiedSampleRate: SAMPLE_RATE)
        SpeechRecognitionService.sharedInstance.sampleRate = SAMPLE_RATE
        _ = AudioController.sharedInstance.start()
        currentInstance.startRecording()
    }
}

extension ViewController: AudioControllerDelegate {
    func processSampleData(_ data: Data) -> Void {
        audioData.append(data)
        
        // We recommend sending samples in 100ms chunks
        let chunkSize : Int /* bytes/chunk */ = Int(0.1 /* seconds/chunk */
            * Double(SAMPLE_RATE) /* samples/second */
            * 2 /* bytes/sample */);
        
        if (audioData.length > chunkSize) {
            SpeechRecognitionService.sharedInstance.streamAudioData(audioData,
                                                                    completion:
                { [weak self] (response, error) in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    if let error = error {
                        print("Error in Google API")
                    } else if let response = response {
                        var finished = false
                        for result in response.resultsArray! {
                            if let result = result as? StreamingRecognitionResult {
                                if result.isFinal {
                                    print(response)
                                    finished = true
                                }
                            }
                        }
                        if finished {
                            //strongSelf.stopAudio(strongSelf)
                        }
                    }
            })
            self.audioData = NSMutableData()
        }
    }
}
