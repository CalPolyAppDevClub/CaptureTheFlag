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
        let playerToAdd = Player(name: playerName, playerNumber: number)
        players.append(playerToAdd)
    }
    
    func getPlayerForNumber(playerNumber: Int) -> Player? {
        for player in players {
            if player.playerNumber == playerNumber {
                return player
            }
        }
        return nil
    }
}
