import PDFKit
import UIKit

class PresentationFileViewController: UIViewController {
    
    var presentationFile: PresentationFile!
    var pdfView: PDFView!
    
    @IBOutlet weak var pdfPreviewView: UIView!
    @IBOutlet weak var instancesTableView: UITableView!
    @IBOutlet weak var noInstancesAvailableLabel: UILabel!
    let CELL_ID = "PresentationInstanceCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instancesTableView.dataSource = self
        instancesTableView.delegate = self
        instancesTableView.separatorStyle = .none
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addTap()
        noInstancesAvailableLabel.isHidden = presentationFile.hasInstances()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpPreviewView()
    }

    @IBAction func createInstanceTapped(_ sender: Any) {
        print("Creating new instance")
    }

    private func setUpPreviewView() {
        pdfView = PDFView(frame: pdfPreviewView.frame)
        pdfView.center = pdfPreviewView.center
        pdfView.document = PDFDocument(url: presentationFile.pdfUrl)
        pdfView.displayDirection = .horizontal
        pdfView.displayMode = .singlePage
        pdfView.autoScales = true
        view.addSubview(pdfView) //FIXME: Will have multple subviews
    }
    
    private func addTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if let yTouchPos = sender?.location(in: view).y {
            if yTouchPos > pdfPreviewView.frame.maxY {
                return
            }
        } else {
            return
        }

        if let xTouchPos = sender?.location(in: view).x {
            if xTouchPos > pdfPreviewView.center.x {
                if pdfView.canGoToNextPage() {
                    pdfView.goToNextPage(sender)
                }
            } else {
                if pdfView.canGoBack() {
                    pdfView.goToPreviousPage(sender)
                }
            }
        }
    }

    @IBAction func unwindToinstanceViewer(segue:UIStoryboardSegue) {
    }

}

extension PresentationFileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentationFile.instances.count
    }
    
    //TODO: Modify - bind with file info
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID, for: indexPath) as! PresentationTableViewCell
        if indexPath.item < presentationFile.instances.count {
        }
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toInstanceCreator" {
            (segue.destination as! PresentationInstanceViewController).currentInstance = presentationFile.createInstance()
        }
    }
}
