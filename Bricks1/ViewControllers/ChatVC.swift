import UIKit
import Firebase
import MessageKit
import MessageInputBar
import FirebaseFirestore

final class ChatVC: MessagesViewController {
    
    private let db = Firestore.firestore()
    private var messagesCollection: CollectionReference?
    private var memberDocument: DocumentReference?
    
    private var messages: [Message] = []
    private var messageListener: ListenerRegistration?
    
    private let currentUser: Member
    private let threadOwner: Member
    private let team: Team
    
    init(currentUser: Member, threadOwner: Member, team: Team) {
        self.currentUser = currentUser
        self.threadOwner = threadOwner
        self.team = team
        super.init(nibName: nil, bundle: nil)
        
        title = threadOwner.displayTask?.description
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let threadPath = ["teams", String(team.teamId), "threads", String(threadOwner.memberId)].joined(separator: "/")
        messagesCollection = db.collection([threadPath, "messages"].joined(separator: "/"))
        memberDocument = db.collection([threadPath, "members"].joined(separator: "/")).document(String(currentUser.memberId))
        
        // listen to changes in Firestore
        messageListener = messagesCollection?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for member thread updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
            // save last message
            if let lastMessage = self.messages.last {
                self.memberDocument?.setData(["lastSeen": lastMessage.messageId], merge: true)
            }
            
            self.scrollToBottom()
        }
        
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        // formatting
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.inputTextView.tintColor = UIColor.black
        messageInputBar.inputTextView.backgroundColor = UIColor.white
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.sendButton.setTitleColor(UIColor.blue, for: .application)
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.setMessageIncomingAvatarSize(.zero)
            layout.setMessageOutgoingAvatarSize(.zero)
        }
        
    }
    
    // MARK: - Helpers
    
    func scrollToBottom() {
        if messages.count > 0 {
            let lastSection = messages.count - 1
            let indexPath = IndexPath(item: 0, section: lastSection)
            messagesCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let message = Message(document: change.document) else {
            print("CHAT VC - FAILED TO LOAD A MESSAGE")
            return
        }
        
        switch change.type {
        case .added:
            addToClient(message)
            
        default:
            break
        }
    }
    
    
    private func addToClient(_ message: Message) {
        guard !messages.contains(message) else {
            return
        }
        
        // load into view
        messages.append(message)
        messages.sort()
        messagesCollectionView.reloadData()
        

    }
    
    private func addToDB(_ message: Message) {
        messagesCollection?.addDocument(data: message.representation) { error in
            if let e = error {
                print("Error sending message: \(e.localizedDescription)")
                return
            }
        }
    }
    
    deinit {
        messageListener?.remove()
    }
}

// MARK: - MessagesDataSource

extension ChatVC: MessagesDataSource {
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func currentSender() -> Sender {
        return Sender(id: String(currentUser.memberId), displayName: currentUser.username)
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    

}


// MARK: - MessageInputBarDelegate

extension ChatVC: MessageInputBarDelegate {
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let message = Message(member: currentUser, content: text)
        
        Fetch.postAssist("MESSAGE", assisteeMemberId: threadOwner.memberId)
        Fetch.postChat(message.content, teamId: team.teamId)
        store.dispatch(FlipAssistArrow())

        addToDB(message)
        inputBar.inputTextView.text = ""
    }
    
}

extension ChatVC: MessagesDisplayDelegate {
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .appleBlue : .incomingMessage
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,
                             in messagesCollectionView: MessagesCollectionView) -> Bool {
        return true
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {

        
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    
}


// MARK: - MessagesLayoutDelegate

extension ChatVC: MessagesLayoutDelegate {
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return CGFloat(integerLiteral: 20)
    }
}

