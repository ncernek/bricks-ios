import SwiftDate

struct Team {
    let name: String
    let teamId: Int
    var members: [Member]
    var otherMembers: [Member]
    let currentUser: Member
//    let threads: [Thread]
    
    init(name: String, teamId: Int, members: [Member] = [Member]()) {
        self.name = name
        self.teamId = teamId
        self.members = members
        
        var otherMembers = [Member]()
        var currentUser = Member.placeholder()
        
        for member in members {
            if member.userId != store.state.userId {
                otherMembers.append(member)
            } else { currentUser = member }
        }
        self.otherMembers = otherMembers
        self.currentUser = currentUser
    }
    
    
    /// for use when converting json
    static func fromDict(_ team: [String: Any?]) -> Team {
        var members = [Member]()
        for member in team["members"] as! [[String: Any?]] {
            members.append(Member.fromDict(member))
        }
        // sort members by consistency
        members.sort() { a, b in
            if a.consistency > b.consistency { return true }
            else { return false }
        }
        
        
        return Team(
            name: team["name"] as! String,
            teamId: team["team_id"] as! Int,
            members: members
        )
    }
    
    func toDict() -> [String: Any?] {
        var members = [[String: Any?]]()
        for member in self.members { members.append( member.toDict() ) }
        
        return [
            "name": self.name,
            "team_id": self.teamId,
            "member_tasks": members
        ]
    }
    
    static func createNewTeam(_ name: String) {
        Fetch.putTeam(name)
    }
}
