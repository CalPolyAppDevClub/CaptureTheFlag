import CoreLocation

class GameLocation {
    var latitude: Double
    var longitude: Double

    init(lat: Double, long: Double) {
        latitude = lat
        longitude = long
    }

    init(loc: CLLocation) {
        latitude = loc.coordinate.latitude
        longitude = loc.coordinate.longitude
    }
    
    static func didTouch(a: GameLocation, b: GameLocation) -> Bool {
        //TODO: implement - are these locations close enought to be touching?
        return false
    }

    static func getAverage(locations: [GameLocation]) -> GameLocation? {
        //TODO: implement - get the 'average' location of all the locations
        return nil
    }
}
