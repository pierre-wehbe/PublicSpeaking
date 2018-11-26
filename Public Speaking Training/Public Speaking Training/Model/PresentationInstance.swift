import AVKit
import Foundation
import PDFKit
import googleapis

class Transcript {
    var sentences: [Sentence] = []
    
    public func isEmpty() -> Bool {
        return sentences.isEmpty
    }
    
    public func getTotalNumberOfWords() -> Int {
        var result = 0
        for sentence in sentences {
            result += sentence.words.count
        }
        return result
    }
}

class Sentence {
    var sentence: String = ""
    var words: [WordInfo] = []
    
    init(sentence: String, words: [WordInfo]) {
        self.sentence = sentence
        self.words = words
    }
}

class PresentationInstance {
    
    // Attributes
    private var _path: String = ""
    private var _currentPage: Int = 0
    private var _parent: PresentationFile!
    private var _audioRecorders : [AVAudioRecorder] = []
    private var _transcripts: [Int : Transcript] = [:]
    private var _pdfDocument: PDFDocument!
    private var _delegate: AVAudioRecorderDelegate!
    private var _instanceName: String = ""
    
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
    
    var instanceName: String {
        get {
            return _instanceName
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
    public func setInstanceName() {
        _instanceName = Date.getDate(date: Date(), format: .YYYYMMDD_HHMMSS).0
    }
    public func startRecording() {
        do {
            _audioRecorders.append(try AVAudioRecorder(url: localFileurl.appendingPathComponent("\(_path)/\(_currentPage).m4a"), settings: settings))
            _audioRecorders[_currentPage].delegate = _delegate
            _audioRecorders[_currentPage].record()
            _transcripts[currentPage] = Transcript()
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
    
    //TODO: Save in currect page given middle world time stapm
    public func addTranscipt(sentence: String, atPage: Int, words: NSMutableArray) {
        let sentenceObj = Sentence(sentence: sentence, words: words as! [WordInfo])
        _transcripts[atPage]!.sentences.append(sentenceObj)
    }

    public func getRecordUrl(forPage: Int = -1) -> URL {
        return FilesManager.localFileURL.appendingPathComponent("\(_path)/\(forPage == -1 ? _currentPage : forPage).m4a")
    }
    
    public func getTranscript(forPage: Int = -1) -> String {
        guard let currentTranscript = _transcripts[forPage == -1 ? _currentPage : forPage] else {return "Nothing has been said on this page."}
        var fullTransctipt = ""
        if currentTranscript.isEmpty() {
            fullTransctipt += "Nothing has been said on this page."
        } else {
            for sentenceObj in currentTranscript.sentences {
                fullTransctipt += "\(sentenceObj.sentence). "
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
            fullTransctipt += getTranscript(forPage: key)
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
        _audioRecorders[_currentPage].pause()
        incrementPage()
        if _currentPage < _audioRecorders.count {
            // resuming
        } else {
//            print("First time reaching that slide, recorder instantiated")
            _transcripts[currentPage] = Transcript()
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
//        print("Paused page \(_currentPage)")
        _audioRecorders[_currentPage].pause()
        if _currentPage == 0 {
            print("ERROR: Page out of range")
            return
        }
        decrementPage()
//        print("Resuming Record at page \(_currentPage)")
        _audioRecorders[_currentPage].record()
    }
    
    //MARK: Stats
    public func getWordsPerMin(forPage: Int = -1) -> Int {
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: getRecordUrl(forPage: forPage))
            guard let transcipt = _transcripts[forPage == -1 ? _currentPage : forPage] else {return 0}
            if transcipt.isEmpty() {
                return 0
            }
            print("Page\(forPage == -1 ? _currentPage : forPage) rate: \(transcipt.getTotalNumberOfWords()*60/Int(audioPlayer.duration))")
            return transcipt.getTotalNumberOfWords()*60/Int(audioPlayer.duration)
        } catch {
            print("Cannot Get Words Per Min for page \(forPage == -1 ? _currentPage : forPage)")
            return 0
        }
        
    }
    
    public func getTotalAverageWordsPerMin() -> Int { //Or get it by counting number of words in the full transcript
        var average = 0
        var totalAmountOfSeconds = 0
        for key in _transcripts.keys {
            let stat = getWordsPerMin(forPage: key)
            if stat != 0 {
                average += stat
                totalAmountOfSeconds += 1
            }
        }
        return average/totalAmountOfSeconds
    }
}
