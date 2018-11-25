import UIKit
import MessageUI

class TranscriptViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var transcriptField: UITextView!
    var currentInstance: PresentationInstance!
    var fromDetailedSummary: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transcriptField.text = currentInstance.generateTranscript()
    }

    @IBAction func emailTapped(_ sender: Any) {
        sendEmail()
    }

    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
//            mail.setToRecipients(["you@yoursite.com"])
            mail.setMessageBody("<p>\(currentInstance.generateTranscript())</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
            print("Can't send email")
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.performSegue(withIdentifier: fromDetailedSummary ? "unwindToDetailedSummary" : "unwindToSummary", sender: self)
    }
}
