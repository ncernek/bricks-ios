import Firebase
import MessageKit
import FirebaseFirestore

struct Message: MessageType {
        
    let id: String?
    let content: String
    let sentDate: Date
    let sender: Sender
    
    var kind: MessageKind {
        return .text(content)
    }
    
    var messageId: String {
        return id ?? UUID().uuidString
    }
    
    var downloadURL: URL? = nil
    
    init(member: Member, content: String) {
        sender = Sender(id: String(member.memberId), displayName: member.username)
        self.content = content
        sentDate = Date()
        id = nil
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        let timestamp = data["created"] as! Timestamp
        sentDate = timestamp.dateValue()
        let senderID = data["senderID"] as! String
        let senderName = data["senderName"] as! String
        
        id = document.documentID
        
        sender = Sender(id: senderID, displayName: senderName)
        
        content = data["content"] as! String
    }
}

extension Message: DatabaseRepresentation {
    
    var representation: [String : Any] {
        var rep: [String : Any] = [
            "created": sentDate,
            "senderID": sender.id,
            "senderName": sender.displayName
        ]
        
        if let url = downloadURL {
            rep["url"] = url.absoluteString
        } else {
            rep["content"] = content
        }
        
        return rep
    }
    
}

extension Message: Comparable {
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
    
}


protocol DatabaseRepresentation {
    var representation: [String: Any] { get }
}
