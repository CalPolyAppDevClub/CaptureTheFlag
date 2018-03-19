import Foundation

class Player: Hashable, CustomStringConvertible {
    //The Hashable protocol allows Player to be a key in a dictionary.
    
    var hashValue: Int //part of the Hashable protocol
    
    var name: String //the name of the player
    //var photo: URL? //the URL for the player's photo
    var location: GameLocation? //the location of the player. Nil if unknown.
    //var hasFlag: Bool = false
    let playerNumber: Int

    //init(name: String, photo: URL?) {
       // self.name = name
       // self.photo = photo
        
        //TODO: compute the hash value of the player
       //hashValue = 0
    //}
    
    //Temporary Init
    init(name: String, playerNumber: Int) {
        self.name = name
        self.playerNumber = playerNumber
        hashValue = playerNumber*4
    }
    public var description: String {
        return "\(String(self.playerNumber)) \(self.name) "
    }
    
    static func ==(lhs: Player, rhs: Player) -> Bool {
        //TODO: implement
        return false
    }
}
