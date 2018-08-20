//
//  MapViewController.swift
//  CaptureTheFlag
//
//  Created by Ethan Abrams on 5/26/18.

//

import UIKit
import MapKit
import CoreLocation

@objc class PlayerAnnotaton: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var team: Int?
    let playerId: String
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, team: Int, playerId: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.team = team
        self.playerId = playerId
        super.init()
    }
}

@objc class FlagAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var team: Int?
    var flagId: String
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, team: Int, flagId: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.team = team
        self.flagId = flagId
        super.init()
    }
}



class MapFlagPlacementViewController: CaptureTheFlagViewController, UIGestureRecognizerDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var map: MKMapView!
    var players = [String:Player]()
    var teams = [Int:Team]()
    var flags = [String:Flag]()
    var userPlayer: Player?
    
    var playerAnnotations = [String:MKAnnotation]()
    var flagAnnotations = [String:MKAnnotation]()
    
    var listenerKeys = [GameListenerKey]()
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpLocation()
        self.map.delegate = self
        self.serverAccess?.onReconnect = {
            self.serverAccess?.getCurrentGameState(callback: {(playersFlagsTeams, error) in
                if error != nil {
                    self.handleError(error!)
                } else {
                    let players = playersFlagsTeams?.0
                    let flags = playersFlagsTeams?.1
                    let teams = playersFlagsTeams?.2
                    self.updateData(players: players!, flags: flags!, teams: teams!)
                    self.reloadMap()
                }
            })
        }
        if self.players.count == 0 {
            self.serverAccess?.getCurrentGameState(callback: {(playersFlagsTeams, error) in
                if error != nil {
                    self.handleError(error!)
                } else {
                    let players = playersFlagsTeams?.0
                    let flags = playersFlagsTeams?.1
                    let teams = playersFlagsTeams?.2
                    self.updateData(players: players!, flags: flags!, teams: teams!)
                    self.reloadMap()
                    self.serverAccess?.getPlayerGameInfo(callback: {(player, error) in
                        if error != nil {
                            self.handleError(error!)
                        } else {
                            self.userPlayer = self.players[player!.id]
                        }
                    })
                }
            })
        }
        self.createListeners()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(createFlag(gestureRecognizer:)))
        self.map?.addGestureRecognizer(tapGesture)
    }
    
    
    @objc func createFlag(gestureRecognizer: UITapGestureRecognizer) {
        let touchpoint = gestureRecognizer.location(in: self.map)
        let locationTapped = self.map?.convert(touchpoint, toCoordinateFrom: self.map)
        self.serverAccess?.createFlag(latitude: String(locationTapped!.latitude), longitude: String(locationTapped!.longitude), callback: {(error) in
            if error != nil {
                self.handleError(error!)
            }
        })
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let flagAnnotation = annotation as? FlagAnnotation {
            var annotationView = self.map?.dequeueReusableAnnotationView(withIdentifier: "flag")
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: flagAnnotation, reuseIdentifier: "flag")
            }
            if flagAnnotation.team == 1 {
                annotationView?.image = UIImage(named: "RedFlag")
                annotationView?.centerOffset = CGPoint(x:22,y: -20)
            } else {
                annotationView?.image = UIImage(named: "BlueFlag")
                annotationView?.centerOffset = CGPoint(x:22, y:-20)
            }
            return annotationView
        }
        if let playerAnnotation = annotation as? PlayerAnnotaton {
            var annotationView: MKMarkerAnnotationView?
            if playerAnnotation.team == 1 {
                annotationView = self.map.dequeueReusableAnnotationView(withIdentifier: "team1") as? MKMarkerAnnotationView
                if annotationView == nil {
                    annotationView = MKMarkerAnnotationView(annotation: playerAnnotation, reuseIdentifier: "team1")
                    annotationView?.markerTintColor = UIColor.red
                }
            } else if playerAnnotation.team == 2 {
                annotationView = self.map.dequeueReusableAnnotationView(withIdentifier: "team2") as? MKMarkerAnnotationView
                if annotationView == nil {
                    annotationView = MKMarkerAnnotationView(annotation: playerAnnotation, reuseIdentifier: "team2")
                    annotationView?.markerTintColor = UIColor.blue
                }
            }
            return annotationView
        }
        return nil
    }
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let playerAnnotation = view.annotation! as? PlayerAnnotaton {
            self.serverAccess?.tagPlayer(id: playerAnnotation.playerId, callback: {(error) in
                if error != nil {
                    print(error!.rawValue)
                    //self.handleError(error!)
                }
            })
        } else if let flagAnnotation = view.annotation! as? FlagAnnotation {
            self.serverAccess?.pickUpFlag(flagId: flagAnnotation.flagId, callback: {(error) in
                if error != nil {
                    print("Tagging: \(error!)")
                    self.handleError(error!)
                }
            })
        }
    }
    
    private func createPlayerAnnotation(team: String) {
        
    }
    
    private func updateData(players: [Player], flags: [Flag], teams: [Team]) {
        self.players.removeAll()
        self.flags.removeAll()
        self.teams.removeAll()
        for player in players {
            self.players[player.id] = player
        }
        for flag in flags {
            self.flags[flag.id] = flag
        }
        for team in teams {
            self.teams[team.id] = team
        }
    }
    
    private func reloadMap() {
        for (_, player) in self.players {
            if let playerAnnotation = self.playerAnnotations[player.id] {
                self.map.removeAnnotation(playerAnnotation)
                self.playerAnnotations.removeValue(forKey: player.id)
            }
            self.addToMap(player: player)
        }
        for (_, flag) in self.flags {
            if let flagAnnotation = self.flagAnnotations[flag.id] {
                self.map.removeAnnotation(flagAnnotation)
                self.flagAnnotations.removeValue(forKey: flag.id)
            }
            self.addToMap(flag: flag)
        }
    }
    
    
    
    private func addToMap(player: Player) {
        if let playerLocation = player.location {
            let coordinate = CLLocationCoordinate2D(latitude: Double(playerLocation.latitude)!, longitude: Double(playerLocation.longitude)!)
            var teamName = "no team"
            var teamId: Int?
            for team in teams.values {
                if team.contians(playerId: player.id) {
                    teamName = team.name
                    teamId = team.id
                    break
                }
            }
            let annotation = PlayerAnnotaton(coordinate: coordinate, title: player.name, subtitle: teamName, team: teamId!, playerId: player.id)
            self.playerAnnotations[player.id] = annotation
            self.map?.addAnnotation(annotation)
        }
    }
    
    private func addToMap(flag: Flag) {
        let flagLocation = flag.location
        let coordinate = CLLocationCoordinate2D(latitude: Double(flagLocation!.latitude)!, longitude: Double(flagLocation!.longitude)!)
        var teamName = "no team"
        var teamId: Int?
        for team in teams.values {
            if team.contains(flagId: flag.id) {
                teamName = team.name
                teamId = team.id
                break
            }
        }
        let annotation = FlagAnnotation(coordinate: coordinate, title: "Flag", subtitle: teamName, team: teamId!, flagId: flag.id)
        self.flagAnnotations[flag.id] = annotation
        self.map?.addAnnotation(annotation)
    }
    
    
    @IBAction func startGame(_ sender: Any) {
        self.serverAccess?.nextGameState(callback: {(error) in
            if error != nil {
                self.handleError(error!)
            }
        })
    }
    
    private func createListeners() {
        let listenerArray: [GameListenerKey] = [
            (self.serverAccess?.addLocationListener(callback: {(playerId, location) in
                if let player = self.players[playerId] {
                    player.location = location
                    if let annotation = self.playerAnnotations[player.id] {
                        self.playerAnnotations.removeValue(forKey: playerId)
                        self.map?.removeAnnotation(annotation)
                    }
                    self.addToMap(player: player)
                }
            }))!,
            
            (self.serverAccess?.addFlagAddedListener(callback: {(flag, teamIdOfFlag) in
                self.flags[flag.id] = flag
                self.teams[teamIdOfFlag]?.addFlag(id: flag.id)
                self.addToMap(flag: flag)
            }))!,
            
            (self.serverAccess?.addGameStateChangedListener(callback: {(gameState) in
                print("New game state: \(gameState)")
            }))!,
            
            (self.serverAccess?.addPlayerTaggedListener(callback: {(playerId, flagHeldLocation) in
                let player = self.players[playerId]!
                player.isTagged = true
                if let flagHeldId = player.flagHeld {
                    player.flagHeld = nil
                    self.flags[flagHeldId]!.held = false
                    self.flags[flagHeldId]!.location = flagHeldLocation!
                    self.addToMap(flag: self.flags[flagHeldId]!)
                }
            }))!,
            
            (self.serverAccess?.addFlagPickedUpListener(callback: {(flagId, playerId) in
                self.flags[flagId]!.held = true
                self.players[playerId]!.flagHeld = flagId
                self.map.removeAnnotation(self.flagAnnotations[flagId]!)
            }))!
        ]
        self.listenerKeys.append(contentsOf: [])
    }
    
    
    
    func handleError(_ error: GameError) {
        print(error)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func printInfo(_ sender: Any) {
        print(self.userPlayer?.flagHeld!)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.serverAccess?.updateLocation(latitude: String(locations.last!.coordinate.latitude), longitude: String(locations.last!.coordinate.longitude))
    }
    
    private func setUpLocation() {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.startUpdatingLocation()
    }
}
