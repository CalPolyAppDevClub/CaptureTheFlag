
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
        self.addPlayer(player: "Main Player")
        self.addOberervers()
    }
    
    func addOberervers() {
        self.ref.child(self.game!.id!).child("Players").observe(DataEventType.childAdded) { (snapshot) in
            self.game!.players.append(Player(name: snapshot.value as! String, playerNumber: Int(snapshot.key)!))
        }
    }
    
    func joinGame(key: String) {
        ref.child(key).child("Name").observeSingleEvent(of: DataEventType.value) { (snapshot) in
            self.game = Game(name: snapshot.value! as! String)
            self.game!.id = key
            self.ref.child(self.game!.id!).child("Players").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                let players = snapshot.children
                let playerList = players.allObjects
                for item in playerList {
                    let itemData = item as! DataSnapshot
                    self.game!.players.append(Player(name: itemData.value as! String, playerNumber: Int(itemData.key)!))
                }
            })
            
        }
        
    }
    
    func addPlayer(player: String) {
        self.ref.child(self.game!.id!).child("Players").observeSingleEvent(of: DataEventType.value) { (snapshot) in
            let players = snapshot.children
            let playerList = players.allObjects
            let count = playerList.count
            var counter = 1
            if count == 0 {
                self.ref.child(self.game!.id!).child("Players").child("1").setValue(player)
            }
            for item in playerList {
                let tempItem = item as! DataSnapshot
                if counter == count {
                    let lastPlayerNumber = Int(tempItem.key)!
                    let playerToAddNumber = lastPlayerNumber + 1
                    self.game?.addPlayer(playerName: player, number: playerToAddNumber)
                    self.ref.child(self.game!.id!).child("Players").child(String(playerToAddNumber)).setValue(player)
                }
                counter += 1
                
            }
            
        }
    }
    
    
    
    
    
    
    
}
