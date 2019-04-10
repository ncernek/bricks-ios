struct AppUser {
    var id: Int
    var username: String
    var email: String
    var chatNotifs: Bool
    var taskNotifs: Bool
    
    init(id: Int, username: String, email: String, chatNotifs: Bool, taskNotifs: Bool) {
        self.id = id
        self.username = username
        self.email = email
        self.chatNotifs = chatNotifs
        self.taskNotifs = taskNotifs
    }
    
    func toDict() -> [String: Any] {
        return [
            "id": self.id,
            "username": self.username,
            "email": self.email,
            "chat_notifs": self.chatNotifs,
            "task_notifs": self.taskNotifs
        ]
    }
    
    static func fromDict(_ data: [String: Any]) -> AppUser {
        return AppUser(
            id: data["id"] as! Int,
            username: data["username"] as! String,
            email: data["email"] as! String,
            chatNotifs: data["chat_notifs"] as! Bool,
            taskNotifs: data["task_notifs"] as! Bool)
    }
}
