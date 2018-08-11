import Foundation


class Player: CustomStringConvertible, Codable, Moveable {
    //var hashValue: Int //part of the Hashable protocol
    var name: String?
    let id: String
    var flagHeld: String?
    var location: Location?
    var leader = false
    var isTagged = false
    
    //weak var delegate: PlayerLocationDelegate? = nil
    

    init(name: String, id: String, flagHeld: String?, location: String?, leader: Bool, isTagged: Bool?) {
        self.name = name
        self.id = id
        self.flagHeld = flagHeld
        //if location != nil {
            //self.location = CLLocation(locationAsString: location!)
        //}
        self.leader = leader
        
        
        
        
    }
    public var description: String {
        return "ID: \(String(self.id)) NAME: \(self.name) FLAGHELD: \(self.flagHeld) LOCATION: \(self.location) LEADER: \(self.leader)"
    }
    
    static func ==(player1: Player, player2: Player) -> Bool {
        return player1.name == player2.name && player1.id == player2.id
    }
    
    
    
}
