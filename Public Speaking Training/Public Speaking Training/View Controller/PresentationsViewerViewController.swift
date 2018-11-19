import UIKit

class PresentationsViewerViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var selectedFile = -1
    
    var files: [PresentationFile] = []
    let CELL_ID = "PresentationFileCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        fetchFiles()
    }
    
    func fetchFiles() {
        files.append(PresentationFile())
        files.append(PresentationFile())
    }
    
}

extension PresentationsViewerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID, for: indexPath) as! PresentationTableViewCell
        if indexPath.item < files.count {
            cell.bind(file: files[indexPath.item])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.item < files.count {
            selectedFile = indexPath.item
            performSegue(withIdentifier: "toPresentationFileView", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPresentationFileView" {
            (segue.destination as! PresentationFileViewController).presentationFile = files[selectedFile]
        }
    }
}
