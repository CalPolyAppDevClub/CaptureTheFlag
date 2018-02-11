class GameManager {
    var isHost: Bool
    var players: [Player]
    var currentGame: Game?

    var isPlaying {
        get {
            //how to we know we're playing the game
        }
        set {
            
        }
    }

    GameManager(gameId: String) {
        //created as a player
    }

    GameManager() {
        //created as a host
    }

    func playerJoined(player: Player) {
        //when a player joins the lobby
    }

    func playerLeft(player: Player) {
        //when a player leaves the lobby
    }

    func playerAssigned(player: Player, teamId: String) {
        //when a player is assigned to a team
    }

}