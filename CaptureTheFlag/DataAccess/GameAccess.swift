
//

//  FirebaseAccess.swift

//  CaptureTheFlag

//

//  Created by Ethan Abrams on 2/25/18.

//  Copyright © 2018 Joe Durand. All rights reserved.

//

import Foundation
import Firebase
import CoreLocation
class GameAccess: NSObject, CLLocationManagerDelegate{
    private var ref = Database.database().reference()
    var locationManager = CLLocationManager()
    var game: Game?
    var userPlayer: Player?
    var gameCreator = false
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        self.updatePlayerLocation(location: location)
    }

    
    func joinGame(key: String, playerName: String) {
        if self.game == nil {
            ref.child(key).child("Name").observeSingleEvent(of: DataEventType.value) { (snapshot) in
                if let snapshotValue = snapshot.value as? String {
                    self.game = Game(name: snapshotValue)
                    self.game!.id = key
                    self.ref.child(self.game!.id!).child("Players").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                        self.addPlayer(player: playerName, complete: {() in
                            if self.userPlayer == nil {
                                self.game = nil
                            } else {
                                self.addObservers()
                            }
                        })
                        
                    })
                }
            }
        }
    }
    
    func removePlayer(player: Int) {
        self.ref.child(self.game!.id!).child("Players").child(String(player)).removeValue()
    }
    
    func createGame(gameName: String, playerName: String) {
        if self.game == nil {
            let gameId = ref.childByAutoId().key
            self.ref.child(gameId).child("Name").setValue(gameName)
            self.gameCreator = true
            self.joinGame(key: gameId, playerName: playerName)
        }
    }
    
    func updatePlayerLocation(location: CLLocation) {
        self.userPlayer?.location = location
        self.ref.child(self.game!.id!).child("Players").child(String(self.userPlayer?.playerNumber as! Int)).child("Location").setValue("\(self.userPlayer!.location!.coordinate.latitude),\(self.userPlayer!.location!.coordinate.longitude)")
    }
    
    
    private func addObservers() {
        //Player added
        self.ref.child(self.game!.id!).child("Players").observe(DataEventType.childAdded, with: playerAddedObserverCallback(snapshot:))
        //Player removed
        self.ref.child(self.game!.id!).child("Players").observe(DataEventType.childRemoved, with: playerRemovedObserverCallback(snapshot:))
        
        self.ref.child(self.game!.id!).child("Players").observe(DataEventType.childChanged, with: playerPropertiesObserverCallback(snapshot:))
    }

    
    
    
    private func createCLLocation(latitudeAndLogitudeString: String) -> CLLocation {
        var latitude = ""
        var longitude = ""
        var commaPassed = false
        for letter in latitudeAndLogitudeString {
            if letter == "," {
                commaPassed = true
            } else if !commaPassed {
                latitude.append(letter)
            } else {
                longitude.append(letter)
            }
        }
        return CLLocation(latitude: Double(latitude)!, longitude: Double(longitude)!)
    }
    
    
    //must be used with DataEventType.childRemoved
    private func playerRemovedObserverCallback(snapshot: DataSnapshot) {
        var counter = 0
        for item in self.game!.players{
            if item.playerNumber == Int(snapshot.key) {
                self.game!.players.remove(at: counter)
            }
            counter += 1
        }
    }
    
    //must be used with DataEventType.childChanged
    private func playerPropertiesObserverCallback(snapshot: DataSnapshot) {
        let playerNumber = Int(snapshot.key)
        let listOfChildren = snapshot.children.allObjects
        for item in listOfChildren {
            let itemCasted = item as! DataSnapshot
            if itemCasted.key == "Location" {
                if let player = self.game!.getPlayerForNumber(playerNumber: playerNumber!) {
                    if player != userPlayer! {
                        player.location = self.createCLLocation(latitudeAndLogitudeString: itemCasted.value as! String)
                    }
                }
            }
        }
    }
    
    //must be used with DataEventType.childAdded
    private func playerAddedObserverCallback(snapshot: DataSnapshot) {
        let playerChildren = snapshot.children.allObjects
        var name = ""
        for item in playerChildren{
            let itemCasted = item as! DataSnapshot
            if itemCasted.key == "Name" {
                name = itemCasted.value as! String
            }
        }
        
        self.game!.players.append(Player(name: name, playerNumber: Int(snapshot.key)!))
    }
    
    private func addPlayer(player: String, complete: @escaping () -> ()) {
        self.ref.child(self.game!.id!).child("Players").observeSingleEvent(of: DataEventType.value) { (snapshot) in
            let players = snapshot.children
            let playerList = players.allObjects
            let count = playerList.count
            var counter = 1
            if count == 0 {
                self.ref.child(self.game!.id!).child("Players").child("1").child("Name").setValue(player)
                self.userPlayer = Player(name: player, playerNumber: 1)
                self.setUpLocationManager()
            } else {
                for item in playerList {
                    let tempItem = item as! DataSnapshot
                    let tempItemList = tempItem.children.allObjects
                    for item in tempItemList {
                        let itemSnapshot = item as! DataSnapshot
                        if itemSnapshot.key == "Name" && itemSnapshot.value as! String == player {
                            complete()
                            return
                        }
                    }
                    if counter == count {
                        let lastPlayerNumber = Int(tempItem.key)!
                        let playerToAddNumber = lastPlayerNumber + 1
                    self.ref.child(self.game!.id!).child("Players").child(String(playerToAddNumber)).child("Name").setValue(player)
                        self.userPlayer = Player(name: player, playerNumber: playerToAddNumber)
                        self.setUpLocationManager()
                        complete()
                        return
                    }
                    counter += 1
                }
            }
            
        }
    }
    
    private func setUpLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
    }
    
    
}
