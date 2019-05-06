import UIKit

class ChooseTaskVC: UIViewController, UITextViewDelegate {
    @IBOutlet var textField: UITextView!
    @IBOutlet var promptTitle: UILabel!
    
    var dueDelta: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup
        textField.delegate = self
        textField.becomeFirstResponder()
        setPromptTitle()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            Task.createNewTask(textField.text, dueDelta: dueDelta)
            _dismiss()
        }
        return true
    }
    
    @IBAction func triggerCancel(_ sender: Any) {
        _dismiss()
    }
    
    @IBAction func triggerSubmit(_ sender: Any) {
        Task.createNewTask(textField.text, dueDelta: 0)
        _dismiss()
    }
    
    func _dismiss() {
        textField.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    func setPromptTitle() {
        if dueDelta == 0 {
            self.promptTitle.text = "Today"
        } else {
            self.promptTitle.text = "Tomorrow"
        }
    }
}
