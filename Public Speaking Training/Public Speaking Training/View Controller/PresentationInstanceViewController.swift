import AVKit
import PDFKit
import UIKit
import googleapis

class PresentationInstanceViewController: UIViewController {

    private let SAMPLE_RATE = 16000

    public var fileLocalPath: String!
    public var data: Data? = nil
    public var pdfView: PDFView!
    public var currentInstance: PresentationInstance!

    private var audioData: NSMutableData!
    private var timer = Timer()
    
    @IBOutlet weak var currentPageTimerLabel: UILabel!
    @IBOutlet weak var totalTimeElapsed: UILabel!

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var pdfControllerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        AudioController.sharedInstance.delegate = self
        addTap()
        setUpView()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(refreshTimers), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @objc func refreshTimers() {
        totalTimeElapsed.text = "\(stringFromTimeInterval(interval: currentInstance.getTotalElapsedTime()))"
        currentPageTimerLabel.text = "\(stringFromTimeInterval(interval: currentInstance.getCurrenPageElapsedTime()))"
    }
    
    private func setUpView() {
        pdfView = PDFView(frame: pdfControllerView.frame)
        pdfView.center = pdfControllerView.center
        pdfView.document = currentInstance.pdfDocument
        pdfView.displayDirection = .horizontal
        pdfView.displayMode = .singlePage
        pdfView.autoScales = true
        view.addSubview(pdfView)
        currentInstance.delegate = self
        startRecording()
    }
    
    private func addTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if let yTouchPos = sender?.location(in: pdfControllerView).y {
            if yTouchPos < pdfControllerView.frame.minY
                || yTouchPos > pdfControllerView.frame.maxY {
                return
            }
        } else {
            return
        }
        if let xTouchPos = sender?.location(in: pdfControllerView).x {
            if xTouchPos > view.center.x {
                if pdfView.canGoToNextPage() {
                    pdfView.goToNextPage(sender)
                    currentInstance.goToNextPage()
                    refreshTimers()
                }
            } else {
                if pdfView.canGoBack() {
                    pdfView.goToPreviousPage(sender)
                    currentInstance.goToPreviousPage()
                    refreshTimers()
                }
            }
        }
    }
    
    //MARK: Button Actions
    @IBAction func donePresenting(_ sender: Any) {
        _ = AudioController.sharedInstance.stop()
        SpeechRecognitionService.sharedInstance.stopStreaming()
        currentInstance.stopAll()
        print(currentInstance.generateTranscript())
    }
    
    @IBAction func restartTapped(_ sender: Any) {
        currentPageTimerLabel.text = "00:00"
        totalTimeElapsed.text = "00:00"
        pdfView.goToFirstPage(self)
        currentInstance.restart()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToInstanceViewer" {
            (segue.destination as! PresentationFileViewController).presentationFile.saveCurrentInstance()
            (segue.destination as! PresentationFileViewController).instancesTableView.reloadData()
        }
    }
}

extension PresentationInstanceViewController: AVAudioRecorderDelegate {
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

extension PresentationInstanceViewController: AudioControllerDelegate {
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
//                                    print(response)
                                    guard let alternative = result.alternativesArray.firstObject as? SpeechRecognitionAlternative else {return}
                                    print("\n")
//                                    print(alternative)
                                    print(alternative.transcript)
                                    strongSelf.currentInstance.addTranscipt(sentence: alternative.transcript, atPage: strongSelf.currentInstance.currentPage)
                                    print("\n")
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
