import UIKit

class Alerts {
    /// choose task alert for today or tomorrow
    class func chooseTask(_ vc: UIViewController, dueDelta: Int) {
        var dayString = "Today"
        if dueDelta > 0 { dayString = "Tomorrow" }
        let alertController = UIAlertController(title: dayString, message:
            "What's your top task?", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "stack a brick"
            textField.autocapitalizationType = .sentences
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(
            UIAlertAction(title: "Submit", style: .default, handler: { action in
                let textField = alertController.textFields![0]
                Task.createNewTask(textField.text!, dueDelta: dueDelta)
            }))
        vc.present(alertController, animated: true, completion: nil)
    }

    class func gradeTask(_ vc: UIViewController) {
        let alertController = UIAlertController(title: "Grade your progress", message:
            "On a scale of 0 to 5, how well did you do this: \(store.state.latestTask!.description)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        for num in 0...5 {
            alertController.addAction(
                UIAlertAction(title: String(num), style: .default, handler: {action in
                    Task.updateTaskGrade(num)
                }))
        }
        vc.present(alertController, animated: true, completion: nil)
    }

    class func giveFeedback(_ vc: UIViewController, message: String) {
        let alertController = UIAlertController(title: "Feedback", message:
            message , preferredStyle: .alert)
        alertController.addTextField() { textField in
            textField.autocapitalizationType = .sentences
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(
            UIAlertAction(title: "Send", style: .default, handler: { action in
                let textField = alertController.textFields![0]
                Fetch.postFeedback(textField.text!)
            }))
        vc.present(alertController, animated: true, completion: nil)
    }

    class func joinTeam(_ vc: UIViewController) {
        let alertController = UIAlertController(title: "Join a Team", message:
            "If you got a text message to join a team, enter the code here:", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "xxxxxx"
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(
            UIAlertAction(title: "Join", style: .default, handler: { _ in
                let textField = alertController.textFields![0]
                Fetch.joinTeam(code: textField.text!)
            }))
        vc.present(alertController, animated: true, completion: nil)
    }
    
    class func createTeam(_ vc: UIViewController) {
        let alertController = UIAlertController(title: "Create a Team", message:
            "What's your team name?", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Average Joe's"
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(
            UIAlertAction(title: "Create", style: .default, handler: { action in
                let textField = alertController.textFields![0]
                Team.createNewTeam(textField.text!)
            }))
        vc.present(alertController, animated: true, completion: nil)
    }
    
    class func inviteFriend(_ vc: UIViewController, team: Team) {
        let alertController = UIAlertController(title: "Invite to \(team.name)", message:
            "Enter your friend's phone number:", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "all formats accepted"
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(
            UIAlertAction(title: "Send", style: .default, handler: { action in
                let textField = alertController.textFields![0]
                Fetch.postInvitation(phoneNumber: textField.text!, teamId: team.teamId)
            }))
        vc.present(alertController, animated: true, completion: nil)
    }
    
    class func confirmation(_ vc: UIViewController, title: String, message: String) {
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: .alert)
        vc.present(alertController, animated: true, completion: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            alertController.dismiss(animated: true, completion: nil)
        }
    }
    
    class func welcomeMenu(_ vc: UIViewController) {
        let alertController = UIAlertController(title: "Welcome!", message:
            "If you received a confirmation code, join your friend's team here. Otherwise, you can create a new team and invite your friends!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Join a team", style: .default) { _ in
            joinTeam(vc)
        })
        alertController.addAction(UIAlertAction(title: "Create a team", style: .default) { _ in
            createTeam(vc)
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        vc.present(alertController, animated: true, completion: nil)
    }
    
    class func info(_ vc: UIViewController, title: String, message: String) {
        
        // format message body
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        let attributedMessage = NSMutableAttributedString(
            string: message,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
        )
        
        let alertController = UIAlertController()
        alertController.setValue(title, forKey: "title")
        alertController.setValue(attributedMessage, forKey: "attributedMessage")
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        alertController.addAction(
            UIAlertAction(title: "I don't get it", style: .default, handler: { action in
                Alerts.giveFeedback(vc, message: "What is confusing?")
            }))
        vc.present(alertController, animated: true, completion: nil)
    }
}
