import Foundation
import UIKit

class FilesManager {
    
    static let shared = FilesManager()
    static let localFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    private init(){
        print("Files Manager Initialized")
    }

    private var presentationsPath: String {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Presentations").path
    }

    func createFile(localPath: String) {
        let filePath = FilesManager.localFileURL.appendingPathComponent(localPath)
        if !FileManager.default.fileExists(atPath: filePath.path) {
            do {
                try FileManager.default.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                NSLog("Couldn't create document directory")
            }
        }
    }
    
    func createPresentationFolder() -> String {
        let parentFolderName = NSUUID().uuidString
        createFile(localPath: "Presentations/\(parentFolderName)")
        return parentFolderName as String
    }
    
    func createInstanceFolder(localPath: String) -> String {
        let parentFolderName = NSUUID().uuidString
        createFile(localPath: "\(localPath)/\(parentFolderName)")
        return "\(localPath)/\(parentFolderName)" as String
    }
    
    func deleteFileAt(localPath: String) {
        let filePath = FilesManager.localFileURL.appendingPathComponent(localPath)
        do {
            try FileManager.default.removeItem(at: filePath)
        } catch {
            print("Couldn't delete files at \(localPath)")
        }
    }
}
