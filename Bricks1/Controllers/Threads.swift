import UIKit
import Firebase
import MessageKit
import MessageInputBar
import FirebaseFirestore
import ReSwift

class Thread {
    
    private let db = Firestore.firestore()
    private var messagesCollection: CollectionReference?
    private var memberDocument: DocumentReference?
    
    private var messages: [Message] = []
    private var messageListener: ListenerRegistration?
    private var memberData: [String: Any] = ["lastSeen": "placeholder"]
    private var memberListener: ListenerRegistration?
    var memberListenerIsActive = false
    
    
    private let currentUser: Member
    private let threadOwner: Member
    private let team: Team
    let teamIndex: Int
    let memberIndex: Int
    var unreadMessageCount: Int = 0
    
    init(currentUser: Member, threadOwner: Member, team: Team, teamIndex: Int, memberIndex: Int) {
        self.currentUser = currentUser
        self.threadOwner = threadOwner
        self.team = team
        self.teamIndex = teamIndex
        self.memberIndex = memberIndex
        
        // set location of data in firestore
        let threadPath = ["teams", String(team.teamId), "threads", String(threadOwner.memberId)].joined(separator: "/")
        messagesCollection = db.collection([threadPath, "messages"].joined(separator: "/"))
        memberDocument = db.collection([threadPath, "members"].joined(separator: "/")).document(String(currentUser.memberId))
        
        // listen to changes in Messages Collection
        messageListener = messagesCollection?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for member thread updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
            // only count unreads if the member data has been checked
            if self.memberListenerIsActive { self.countUnreadMessages() }
        }
        
        // listen to changes in MemberDocument
        memberListener = memberDocument?.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }

            if let data = document.data(), !data.isEmpty { self.memberData = data }
            self.countUnreadMessages()
            self.memberListenerIsActive = true
        }
    }

    // MARK: - Helpers
    
    private func handleDocumentChange(_ change: DocumentChange) {
        let message = Message(document: change.document)
        
        switch change.type {
        case .added:
            addToClient(message!)
            
        default:
            break
        }
    }
    
    private func addToClient(_ message: Message) {
        guard !messages.contains(message) else {
            return
        }
        messages.append(message)
        messages.sort()
    }
    
    func countUnreadMessages() {
        var noMatch = true
        // only update unreadMessageCount if there are messages, and if lastSeen is not a placeholder
        if messages.count > 0 {
            for (index, message) in messages.enumerated() {
                if message.messageId == memberData["lastSeen"] as! String {
                    noMatch = false
                    unreadMessageCount = messages.count - (index + 1)
                }
            }
            if noMatch { unreadMessageCount = messages.count }
            
            store.dispatch(SaveUnreadMessageCount(teamIndex: teamIndex, memberIndex: memberIndex, unreadMessageCount: unreadMessageCount))
        }
    }
    
    deinit {
        messageListener?.remove()
        memberListener?.remove()
    }
}

// TODO the substate subscription doesnt work well
class Threads: StoreSubscriber {
    
    var threads = [Int: Thread]()
    typealias StoreSubscriberStateType = [Team]
    
    func newState(state: [Team]) {
//            makeThreads(state)
    }
    
    init() {
//        makeThreads(store.state.teams)
        // only listen to changes in teams on state
        store.subscribe(self) { subcription in
            subcription.select { state in state.teams }
        }
    }
    
    class func makeThreads(_ teams: [Team]) {
        for (i1, team) in teams.enumerated() {
            for (i2, member) in team.members.enumerated() {
                _ = Thread(currentUser: team.currentUser, threadOwner: member, team: team, teamIndex: i1, memberIndex: i2)
                print("THREAD CREATED: ", member.username, String(member.memberId))
            }
        }
    }
}
