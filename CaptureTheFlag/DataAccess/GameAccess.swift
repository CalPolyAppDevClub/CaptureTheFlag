
//

//  FirebaseAccess.swift

//  CaptureTheFlag

//

//  Created by Ethan Abrams on 2/25/18.

//  Copyright © 2018 Joe Durand. All rights reserved.

//

import Foundation
import Firebase
class GameAccess {
    private var ref = Database.database().reference()
    var game: Game?
    var gameCreator = false
    
    func createGame(game: Game, playerName: String) {
        self.game = game
        self.game!.id = ref.childByAutoId().key
        self.ref.child(self.game!.id!).child("Name").setValue(self.game!.name)
        self.gameCreator = true
        self.joinGame(key: self.game!.id!, playerName: playerName)
        
    }
    
    
    private func addObservers() {
        //Player added observer
        self.ref.child(self.game!.id!).child("Players").observe(DataEventType.childAdded) { (snapshot) in
            self.game!.players.append(Player(name: snapshot.value as! String, playerNumber: Int(snapshot.key)!))
        }
        //Player removed observer
        self.ref.child(self.game!.id!).child("Players").observe(DataEventType.childRemoved) { (snapshot) in
            var counter = 0
            for item in self.game!.players{
                if item.playerNumber == Int(snapshot.key) {
                    self.game!.players.remove(at: counter)
                }
                counter += 1
            }
        }
    }
    
    func joinGame(key: String, playerName: String) {
        ref.child(key).child("Name").observeSingleEvent(of: DataEventType.value) { (snapshot) in
            self.game = Game(name: snapshot.value! as! String)
            self.game!.id = key
            self.ref.child(self.game!.id!).child("Players").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                self.addObservers()
                self.addPlayer(player: playerName)
            })
        }
    }
    
    func removePlayer(player: Int) {
        self.ref.child(self.game!.id!).child("Players").child(String(player)).removeValue()
    }

    
    private func addPlayer(player: String) {
        self.ref.child(self.game!.id!).child("Players").observeSingleEvent(of: DataEventType.value) { (snapshot) in
            let players = snapshot.children
            let playerList = players.allObjects
            let count = playerList.count
            var counter = 1
            if count == 0 {
                self.ref.child(self.game!.id!).child("Players").child("1").setValue(player)
            } else {
                for item in playerList {
                    let tempItem = item as! DataSnapshot
                    if counter == count {
                        let lastPlayerNumber = Int(tempItem.key)!
                        let playerToAddNumber = lastPlayerNumber + 1
                        //self.game?.addPlayer(playerName: player, number: playerToAddNumber)
                        self.ref.child(self.game!.id!).child("Players").child(String(playerToAddNumber)).setValue(player)
                    }
                    counter += 1
                }
                
            }
            
        }
    }
}
