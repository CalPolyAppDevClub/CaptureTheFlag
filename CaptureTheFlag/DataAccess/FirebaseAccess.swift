
//

//  FirebaseAccess.swift

//  CaptureTheFlag

//

//  Created by Ethan Abrams on 2/25/18.

//  Copyright © 2018 Joe Durand. All rights reserved.

//

import Foundation
import Firebase
class FirebaseAccess {
    var ref = Database.database().reference()
    var game: Game?
    var gameCreator = false
    
    func createGame(game: Game) {
        self.game = game
        self.game!.id = ref.childByAutoId().key
        self.ref.child(self.game!.id!).setValue(self.game!.name)
        self.gameCreator = true
    }
    
    func joinGame(key: String) {
        ref.child(key).observeSingleEvent(of: DataEventType.value) { (snapshot) in
            self.game = Game(name: snapshot.value! as! String)
            self.game?.id = key
        }
        
    }
    
    
    
    
    
    
    
}
