
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
    
    func createGame(game: Game, playerName: String) {
        self.game = game
        self.game!.id = ref.childByAutoId().key
        self.ref.child(self.game!.id!).child("Name").setValue(self.game!.name)
        self.gameCreator = true
        self.joinGame(key: self.game!.id!, playerName: playerName)
        
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
    
     func addPlayer(player: String) {
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
                    if counter == count {
                        let lastPlayerNumber = Int(tempItem.key)!
                        let playerToAddNumber = lastPlayerNumber + 1
                        self.ref.child(self.game!.id!).child("Players").child(String(playerToAddNumber)).child("Name").setValue(player)
                        self.userPlayer = Player(name: player, playerNumber: playerToAddNumber)
                        self.setUpLocationManager()
                    }
                    counter += 1
                }
            }
            
        }
    }
    
    private private func setUpLocationManager() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
    }
    
    
}
