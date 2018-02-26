class GameLocation {
    var latitude: Double
    var longitude: Double

    GameLocation(lat: Double, long: Double) {

    }

    static func didTouch(a: GameLocation, b: GameLocation) -> Bool {
        //are these locations touching?
    }

    static func getAverage(locations: [GameLocation]) -> GameLocation {
        //get the 'average' location of all the locations
    }
}