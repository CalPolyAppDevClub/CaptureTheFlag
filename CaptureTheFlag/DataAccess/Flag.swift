import CoreLocation
class Flag: Equatable, Codable, Moveable, CustomStringConvertible{
    var name: String?
    var location: Location?
    let id: String
    var held = false
    
    init(id: String, location: Location) {
        self.id = id
        self.location = location
    }
    
    func updateLocation() {
        
    }

    public var description: String {
        return "name: \(self.name) location: \(self.location) id: \(self.id) held: \(self.held)"
    }
    
    static func == (lhs: Flag, rhs: Flag) -> Bool {
        return lhs.id == rhs.id
    }
}
