import FirebaseUI

class LoginVC: FUIAuthPickerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.leftBarButtonItem = nil
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        view.backgroundColor = .white
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        label.text = "Stack a Brick"
        label.font = label.font.withSize(40)

        
        label.center.x = view.center.x
        label.center.y = view.center.y - 200
        label.textAlignment = .center
        
        self.view.addSubview(label)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
