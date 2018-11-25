import AVKit
import UIKit
import PDFKit

class DetailedSummaryViewController: UIViewController {

    @IBOutlet weak var pdfViewContainer: UIView!
    private var pdfView: PDFView!
    public var currentInstance: PresentationInstance!

    @IBOutlet weak var currentPageTranscipt: UITextView!
    
    private var audioPlayer: AVAudioPlayer? = nil
    @IBOutlet weak var audioPlayerButton: UIButton!
    @IBOutlet weak var audioPlayerBar: UIProgressView!
    @IBOutlet weak var audioPlayerLabel: UILabel!
    var audioPlayerTimer = Timer()
    
    @IBAction func audioPlayerButtonTapped(_ sender: Any) {
        if audioPlayerButton.currentImage == #imageLiteral(resourceName: "play_button.png") {
            audioPlayerButton.setImage(#imageLiteral(resourceName: "pause_button.png"), for: .normal)
            resumeAudioFile()
        } else {
            audioPlayerButton.setImage(#imageLiteral(resourceName: "play_button.png"), for: .normal)
            pauseAudioFile()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTap()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentInstance.currentPage = 0 // initializes to page 0
        audioPlayerBar.setProgress(0, animated: false)
        currentPageTranscipt.text = currentInstance.getTranscript()
        if pdfView != nil {
            pdfView.removeFromSuperview()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpPreviewView()
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
                    stopPlayer()
                }
            } else {
                if pdfView.canGoBack() {
                    pdfView.goToPreviousPage(sender)
                    currentInstance.decrementPage()
                    currentPageTranscipt.text = currentInstance.getTranscript()
                    stopPlayer()
                }
            }
        }
    }
}

extension DetailedSummaryViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPlayer()
    }
    
    func stopPlayer() {
        audioPlayer?.stop()
        audioPlayer = nil
        audioPlayerTimer.invalidate()
        audioPlayerButton.setImage(#imageLiteral(resourceName: "play_button.png"), for: .normal)
        audioPlayerBar.setProgress(0, animated: false)
        audioPlayerLabel.text = "00:00"
    }
    
    public func playAudioFile(forPage: Int = -1) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: currentInstance.getRecordUrl())
            audioPlayer!.delegate = self
            audioPlayerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateAudioPlayerLabel), userInfo: nil, repeats: true)
            audioPlayer!.play()
        } catch{
            print("No Audio")
        }
    }
    
    @objc func updateAudioPlayerLabel() {
        audioPlayerLabel.text = stringFromTimeInterval(interval: audioPlayer!.currentTime) as String
        audioPlayerBar.setProgress(Float(audioPlayer!.currentTime/audioPlayer!.duration), animated: true)
    }

    public func pauseAudioFile(forPage: Int = -1) {
        guard let player = audioPlayer else {return}
        if player.isPlaying {
            player.pause()
        }
    }
    
    public func resumeAudioFile(forPage: Int = -1) {
        guard let player = audioPlayer else {
            playAudioFile()
            return
        }
        player.play()
    }
}
