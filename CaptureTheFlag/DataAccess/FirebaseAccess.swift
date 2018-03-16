
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
        print("Hello")
        ref.child(key).child("Name").observeSingleEvent(of: DataEventType.value) { (snapshot) in
            self.game = Game(name: snapshot.value! as! String)
            self.game!.id = key 
        }
        
    }
    
    func addPlayer(player: String) {
        print("add")
        self.ref.child(self.game!.id!).child("Players").observeSingleEvent(of: DataEventType.value) { (snapshot) in
            var players = snapshot.children
            var playerList = players.allObjects
            var count = playerList.count
            var counter = 1
            print(count)
            for item in playerList {
                var tempItem = item as! DataSnapshot
                if counter == count {
                    var lastPlayerNumber = Int(tempItem.key)!
                    var playerToAddNumber = lastPlayerNumber + 1
                    self.game?.addPlayer(playerName: player, number: playerToAddNumber)
                    self.ref.child(self.game!.id!).child("Players").child(String(playerToAddNumber)).setValue(player)
                }
                counter += 1
                
            }
            
        }
    }
    
    
    
    
    
    
    
}
