class Team: Codable {
    let name: String
    var players = Set<String>()
    var flags = Set<String>()
    var id: Int
    
    init(name: String, id: Int) {
        self.name = name
        self.id = id
    }
    
    func addPlayer(id: String) {
        self.players.insert(id)
    }
    
    func addFlag(id: String) {
        self.flags.insert(id)
    }
    
    func contians(playerId: String) -> Bool {
        return self.players.contains(playerId)
    }
    
    func contains(flagId: String) -> Bool {
        return self.flags.contains(flagId)
    }
}


