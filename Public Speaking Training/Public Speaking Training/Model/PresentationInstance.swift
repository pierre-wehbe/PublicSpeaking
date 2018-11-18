import AVKit
import Foundation
import PDFKit

class PresentationInstance {
    
    // Attributes
    private var _currentPage: Int = 0
    private var _parent: PresentationFile!
    private var _audioRecorders : [AVAudioRecorder] = []
    
    private var _pdfDocument: PDFDocument!
    private var _delegate: AVAudioRecorderDelegate!
    
    
    private let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    private let localFileurl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    init(parent: PresentationFile) {
        self._parent = parent
        self._pdfDocument = PDFDocument(url: parent.pdfUrl)
    }

    // Getters
    var pdfDocument: PDFDocument {
        get {
            return _pdfDocument
        }
    }
    
    var pageCount: Int {
        get {
            return _pdfDocument.pageCount
        }
    }
    
    var delegate: AVAudioRecorderDelegate {
        get {
            return _delegate
        }
        set {
            _delegate = newValue
        }
    }

    // Helper Function
    public func startRecording() {
        do {
            _audioRecorders.append(try AVAudioRecorder(url: localFileurl.appendingPathComponent("test-p\(_currentPage).m4a"), settings: settings))
            _audioRecorders[_currentPage].delegate = _delegate
            _audioRecorders[_currentPage].record()
        } catch {
            print("Couldn't append recorder")
        }
    }
    
    public func stopAll() {
        for recorder in _audioRecorders {
            recorder.stop()
        }
    }
    
    public func goToNextPage() {
        print("\nNext Page")
        print("Paused page \(_currentPage)")
        _audioRecorders[_currentPage].pause()
        _currentPage += 1
        if _currentPage < _audioRecorders.count {
            print("Resuming Record at page \(_currentPage)")
        } else {
            print("First time reaching that slide, recorder instantiated")
            do {
                _audioRecorders.append(try AVAudioRecorder(url: localFileurl.appendingPathComponent("test-p\(_currentPage).m4a"), settings: settings))
                _audioRecorders[_currentPage].delegate = _delegate
            } catch {
                print("Couldn't append recorder")
            }
        }
        _audioRecorders[_currentPage].record()
    }
    
    public func goToPreviousPage() {
        print("\nPrevious Page")
        print("Paused page \(_currentPage)")
        _audioRecorders[_currentPage].pause()
        if _currentPage == 0 {
            print("ERROR: Page out of range")
            return
        }
        _currentPage -= 1
        print("Resuming Record at page \(_currentPage)")
        _audioRecorders[_currentPage].record()
    }
    
}
