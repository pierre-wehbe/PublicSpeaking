import AVKit
import Foundation
import PDFKit

class PresentationInstance {
    
    // Attributes
    private var _path: String = ""
    private var _currentPage: Int = 0
    private var _parent: PresentationFile!
    private var _audioRecorders : [AVAudioRecorder] = []
    private var _transcripts: [Int : [String]] = [:]
    private var _pdfDocument: PDFDocument!
    private var _delegate: AVAudioRecorderDelegate!
    
    private var _currentPageAudioPlayer: AVPlayer!
    
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
        
        self._path = FilesManager.shared.createInstanceFolder(localPath: _parent.path)
        print("Created New instance folder at path: \(_path)")
    }

    // Getters
    var currentPage: Int {
        get {
            return _currentPage
        }
        set {
            _currentPage = newValue
        }
    }

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
            _audioRecorders.append(try AVAudioRecorder(url: localFileurl.appendingPathComponent("\(_path)/\(_currentPage).m4a"), settings: settings))
            _audioRecorders[_currentPage].delegate = _delegate
            _audioRecorders[_currentPage].record()
            _transcripts[currentPage] = []
        } catch {
            print("Couldn't append recorder")
        }
    }
    
    public func stopAll() {
        for recorder in _audioRecorders {
            recorder.stop()
        }
    }
    
    public func restart() {
        stopAll()
        FilesManager.shared.deleteFileAt(localPath: _path)
        self._path = FilesManager.shared.createInstanceFolder(localPath: _parent.path)
        _audioRecorders.removeAll()
        _transcripts.removeAll()
        _currentPage = 0
        startRecording()
    }

    public func getTotalElapsedTime() -> TimeInterval {
        var totalTimeElapsed: TimeInterval = 0
        for recoder in _audioRecorders {
            totalTimeElapsed += recoder.currentTime
        }
        return totalTimeElapsed
    }
    
    public func getCurrenPageElapsedTime() -> TimeInterval {
        if _currentPage < _audioRecorders.count {
            return _audioRecorders[_currentPage].currentTime
        }
        return 0.0
    }
    
    public func addTranscipt(sentence: String, atPage: Int) {
        _transcripts[atPage]?.append(sentence)
    }
    
    public func playAudioFile(forPage: Int = -1) {
        _currentPageAudioPlayer = try? AVPlayer(url: getRecordUrl(forPage: forPage == -1 ? _currentPage : forPage))
        _currentPageAudioPlayer.play()
    }

    private func getRecordUrl(forPage: Int) -> URL {
        print(FilesManager.localFileURL.appendingPathComponent("\(_path)/\(forPage).m4a"))
        return FilesManager.localFileURL.appendingPathComponent("\(_path)/\(forPage).m4a")
    }
    
    public func getTranscript(forPage: Int = -1) -> String {
        guard let currentTranscript = _transcripts[forPage == -1 ? _currentPage : forPage] else {return "Nothing has been said on this page."}
        var fullTransctipt = ""
        if currentTranscript.isEmpty {
            fullTransctipt += "Nothing has been said on this page. "
        } else {
            for sentence in currentTranscript {
                fullTransctipt += "\(sentence). "
            }
        }
        return fullTransctipt
    }

    public func generateTranscript() -> String {
        if _transcripts.isEmpty {
            print("Empty Transcript")
            return ""
        }
        var fullTransctipt: String = "*******************\nFULL TRANSCRIPT\n*******************\n\n"
        for key in _transcripts.keys.sorted(by: { (page1, page2) -> Bool in
            return page1 < page2
        }) {
            fullTransctipt += "\n\nPage \(key):\n"
            if _transcripts[key]!.isEmpty {
                fullTransctipt += "Nothing has been said on this page. "
            }
            for sentence in _transcripts[key]! {
                fullTransctipt += "\(sentence). "
            }
        }
        return fullTransctipt
    }
    
    public func incrementPage() {
        _currentPage += 1
    }
    
    public func decrementPage() {
        _currentPage -= 1
        _currentPage = _currentPage < 0 ? 0 : _currentPage
    }

    //TODO: Add flags on resumed
    public func goToNextPage() {
        print("\nNext Page")
        print("Paused page \(_currentPage)")
        _audioRecorders[_currentPage].pause()
        incrementPage()
        _transcripts[currentPage] = []
        if _currentPage < _audioRecorders.count {
            print("Resuming Record at page \(_currentPage)")
        } else {
            print("First time reaching that slide, recorder instantiated")
            do {
                _audioRecorders.append(try AVAudioRecorder(url: localFileurl.appendingPathComponent("\(_path)/\(_currentPage).m4a"), settings: settings))
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
        decrementPage()
        print("Resuming Record at page \(_currentPage)")
        _audioRecorders[_currentPage].record()
    }
}
