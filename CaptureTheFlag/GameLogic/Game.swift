import Foundation

class Game {
    
    //var startTime: Date
    //var teamA: Team
    //var teamB: Team
    var id: String?
    var name: String
    var players = [Player]()

    init(name: String) {
        //self.startTime = start
        //self.teamA = teamA
        //self.teamB = teamB
        self.name = name
    }
    
    func addPlayer(playerName: String, number: Int) {
        var playerToAdd = Player(name: playerName, playerNumber: number)
        players.append(playerToAdd)
    }
}
