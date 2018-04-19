import Foundation
import Firebase
class FirebaseAccess{
    static private let ref = Database.database().reference()
    
    //Dictionary the closure takes containes all properties of the player
    static func setupPlayerAddedObserver(gameKey: String, callback: @escaping (DataAccessFailureReason?, [PlayerProperty : String]) -> ()) {
        self.playerObserverCreator(gameKey: gameKey, eventType: DataEventType.childAdded, callback: callback)
    }
    
    static func setupPlayerPropertyChangeObserver(gameKey: String, callback: @escaping (DataAccessFailureReason?, [PlayerProperty : String]) -> ()) {
        self.playerObserverCreator(gameKey: gameKey, eventType: DataEventType.childChanged, callback: callback)
    }
    
    static func setupPlayerRemovedObserver(gameKey: String, callback: @escaping (DataAccessFailureReason?, [PlayerProperty : String]) -> ()) {
        self.playerObserverCreator(gameKey: gameKey, eventType: DataEventType.childRemoved, callback: callback)
    }
    
    //requires read and write permissions.
    static func updatePlayerProperties (gameKey: String, playerId: String, propertiesToUpdate: [PlayerProperty: String],
      completion: @escaping (DataAccessFailureReason?) -> ()) {
          self.checkIfGameExists(gameId: gameKey, completion: {(exists, denied) in
            if exists {
                //update properites because there are no issues
                let playerPropertyKeys = Array(propertiesToUpdate.keys)
                var propertiesToAdd = [String:String]()
                for key in playerPropertyKeys {
                    propertiesToAdd[key.rawValue] = propertiesToUpdate[key]
                }
                    self.ref.child(gameKey).child("Players").child(playerId)
                        .setValue(propertiesToAdd, withCompletionBlock: {(error, ref) in
                        if error != nil {
                            completion(DataAccessFailureReason.accessDenied)
                        } else {
                            completion(nil)
                        }
                    })
            } else if denied != nil {
                //access denied.
                completion(denied)
            } else {
                //access granted but invalid key
                completion(DataAccessFailureReason.invalidGameKey)
            }
        })
    }
    
    static func createGame(gameName: String, completion: @escaping (DataAccessFailureReason?, String?) -> ()) {
        let gameId = ref.childByAutoId().key
        self.ref.child(gameId).child("Name").setValue(gameName, withCompletionBlock: {(error, ref) in
            if error != nil {
                completion(DataAccessFailureReason.accessDenied, nil)
            } else {
                //Might be able to do this with Firebase Cloud Functions. Adds a game key to the Gameids node.
                //This makes it possible to check if a game exists without downloading an entire game.
                self.ref.child("GameIds").child(gameId).setValue(gameId, withCompletionBlock: {(error, ref) in
                    if error != nil {
                        completion(DataAccessFailureReason.accessDenied, nil)
                    } else {
                        completion(nil, gameId)
                    }
                })
            }
        })
    }
    
    static func addPlayer(
        gameKey: String,
        playerId: String,
        playerProperties: [PlayerProperty:String],
        completion: @escaping (DataAccessFailureReason?) -> ()) {
        self.updatePlayerProperties(
            gameKey: gameKey,
            playerId: playerId,
            propertiesToUpdate: playerProperties,
            completion: completion
        )
    }
    
    private static func playerObserverCreator(gameKey: String, eventType: DataEventType, callback: @escaping (DataAccessFailureReason?, [PlayerProperty:String]) -> ()) {
        self.checkIfGameExists(gameId: gameKey, completion: {(exists, failure) in
            if exists {
                self.ref.child(gameKey).child("Players").observe(eventType, with: {(snapshot) in
                    self.packagePlayerDataFromSnapshot(snapshot: snapshot, completion: callback)
                })
            } else if failure != nil {
                callback(DataAccessFailureReason.accessDenied, [PlayerProperty:String]())
            } else {
                callback(DataAccessFailureReason.invalidGameKey, [PlayerProperty:String]())
            }
        })
    }
    
    private static func packagePlayerDataFromSnapshot(snapshot: DataSnapshot, completion: @escaping (DataAccessFailureReason?, [PlayerProperty: String]) -> ()) {
        let playerChildren = snapshot.children.allObjects as! Array<DataSnapshot>
        var playerData = [PlayerProperty: String]()
        playerData[PlayerProperty.playerId] = snapshot.key
        for child in playerChildren {
            playerData[PlayerProperty(rawValue: child.key)!] = child.value as? String
        }
        completion(nil, playerData)
    }
    
     private static func checkIfGameExists(gameId: String, completion: @escaping (Bool, DataAccessFailureReason?) -> ()) {
        self.ref.child("GameId's").child(gameId).observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.exists() {
                completion(true, nil)
            } else {
                print(snapshot.exists())
                completion(false, nil)
            }
        }, withCancel:{(error) in completion(false, DataAccessFailureReason.accessDenied)})
    }
}
