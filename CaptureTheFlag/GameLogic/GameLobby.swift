class GameLobby {
    var gameId: Int
    var isHost: Bool
    var players: [Player]
    var teamSelection: [Player: String]
    var currentGame: Game?

    var isPlaying: Bool {
        get
        {
            return currentGame != nil
        }
    }

    init(gameId: Int) {
        self.gameId = gameId
        isHost = false

        //TODO: Load players from server
        //players = getPlayersFromServer() - teamselection, getPlayersTeamFromServer()
        players = []
        teamSelection = [:]
    }

    init() {
        isHost = true
        players = []
        teamSelection = [:]
        //TODO: add ourselves
        gameId = 1234 //TODO: get a gameId from the server
    }

    func playerJoined(player: Player) {
        players.append(player)
    }

    func playerLeft(player: Player) {
        //TODO: remove the player from the player list.
    }

    func playerAssigned(player: Player, teamId: String) {
        teamSelection[player] = teamId
    }

    func startGame() {
        //TODO
    }
}
