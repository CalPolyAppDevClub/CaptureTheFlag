class Flag {
    var home: GameLocation
    var heldBy: Player? //tracks what player is holding the flag. Nil if at home.

    var location: GameLocation? { //tracks the current location of the flag
        get
        {
            if let player = heldBy {
                return player.location
            }
            else {
                return home
            }
        }
    }

    init(homeLocation: GameLocation) {
        self.home = homeLocation
    }
}
