
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
        self.ref.child(self.game!.id!).child("Name").setValue(self.game!.name)
        self.gameCreator = true
    }
    
    func joinGame(key: String) {
        ref.child(key).child("Name").observeSingleEvent(of: DataEventType.value) { (snapshot) in
            //no optional chaining yet
            self.game = Game(name: snapshot.value! as! String)
            self.game?.id = key
        }
        
    }
    
    //func addPlayer(player: Player) {
        //self.ref.child(self.game!.id!).child("Players").child("")
    //}
    
    
    
    
    
    
    
}
