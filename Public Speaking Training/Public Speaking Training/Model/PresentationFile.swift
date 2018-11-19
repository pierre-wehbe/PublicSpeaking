import Foundation
import PDFKit

class PresentationFile {
    
    // Attributes
    private var _fileName: String = ""
    private var _instances: [PresentationInstance] = []
    private var _pdfUrl: URL!
    
    private var _newInstance: PresentationInstance? = nil
    
    init() {
        let path = Bundle.main.path(forResource: "test", ofType: "pdf") //TODO: temp, get from viewer
        self._pdfUrl = URL(fileURLWithPath: path!)
    }
    
    
    // Getters
    var pdfUrl: URL {
        get {
            return _pdfUrl
        }
    }
    
    var newInstance: PresentationInstance? {
        get {
            return _newInstance
        }
    }
    
    var instances: [PresentationInstance] {
        get {
            return _instances
        }
    }
    
    // Helper Functions
    public func createInstance() -> PresentationInstance {
        if _newInstance != nil {
            print("ERROR: Instance already active\nDelete current instance before creating a new one")
            return _newInstance!
        }
        
        _newInstance = PresentationInstance(parent: self)
        return _newInstance!
    }
    
    public func deleteCurrentInstance() {
        if _newInstance != nil {
            _newInstance = nil
            print("Current instance has been deleted sucessfully")
            return
        } else {
            print("No current instances to be deleted")
            return
        }
    }
    
    public func saveCurrentInstance() {
        if _newInstance != nil {
            _instances.append(_newInstance!)
            //TODO: Save it somewhere
            print("Saved successfully")
            deleteCurrentInstance()
        } else {
            print("No current instances to be saved")
        }
    }
    
    public func hasInstances() -> Bool {
        return !_instances.isEmpty
    }
}
