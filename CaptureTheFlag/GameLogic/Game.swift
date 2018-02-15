import Foundation

class Game {
    
    var startTime: Date
    var teamA: Team
    var teamB: Team

    init(start: Date, teamA: Team, teamB: Team) {
        self.startTime = start
        self.teamA = teamA
        self.teamB = teamB
    }
}
