

import Foundation
import SwiftWebSocket

struct GameListenerKey {
    let key: UUID
    init(key: UUID) {
        self.key = key
    }
}

class ServerAccess {
    private let point: AsyncRequestResponse
    private var listenerKeys = Dictionary<UUID, ListenerKey>()
    
    
    
    init(requestResponse: AsyncRequestResponse) {
        self.point = requestResponse
    }
    
    func addTeamAddedListener(callback: @escaping (Team) -> ()) -> GameListenerKey {
        //print("TEAM ADDED IS BEING CALLED")
        let listenerKey = self.point.addListener(for: "teamAdded", callback: {(data) in
            let dataAsDict = data as! [String:Any]
                do {
                    let team = try self.mapToObject(dictToMap: dataAsDict, type: Team.self)
                    callback(team)
                } catch {
                    print("THIS IS WHERE THE ERROR IS ORCCURING")
                    print(error)
                }
            
        })
        return GameListenerKey(key: listenerKey.key)
    }
    
    func addPlayerJoinedTeamListener(callback: @escaping (String, Int) -> ()) -> GameListenerKey {
        let listenerKey = self.point.addListener(for: "playerJoinedTeam", callback: {(data) in
            let dataDictionary = data as! Dictionary<String, Any>
            let playerId = dataDictionary["id"]
            let teamId = dataDictionary["team"]
            callback(playerId! as! String, teamId! as! Int)
        })
        return GameListenerKey(key: listenerKey.key)
    }
    
    func addLocationListener(callback:  @escaping (String, Location) -> ()) -> GameListenerKey {
        let listenerKey = self.point.addListener(for: "locationUpdate", callback: {(data) in
            let dataAsDict = data as! [String:Any]
            let id = dataAsDict["playerId"] as! String
            let newLocation = dataAsDict["newLocation"] as! [String:Any]
            do {
                let location = try self.mapToObject(dictToMap: newLocation, type: Location.self)
                callback(id, location)
            } catch {
                print(error)
            }
            
        })
        self.listenerKeys[listenerKey.key] = listenerKey
        return GameListenerKey(key: listenerKey.key)
    }
    
    func removeListener(_ gameListerKey: GameListenerKey) {
        if self.listenerKeys[gameListerKey.key] != nil {
            self.point.removeListener(listenerKey: self.listenerKeys[gameListerKey.key]!)
            self.listenerKeys.removeValue(forKey: gameListerKey.key)
        }
    }
    
    func addPlayerAddedListener(callback: @escaping (Player) -> ()) -> GameListenerKey {
        let listenerKey = self.point.addListener(for: "playerAdded", callback: {(data) in
            do {
                let player = try self.mapToObject(dictToMap: data as! Dictionary<String, Any>, type: Player.self)
                callback(player)
            } catch {
                print(error)
            }
        })
        return GameListenerKey(key: listenerKey.key)
    }
    
    func addPlayerRemovedListener(callback: @escaping (String) -> ()) -> GameListenerKey {
        let listenerKey = self.point.addListener(for: "playerRemoved", callback: {(data) in
            let playerId = data as! String
            callback(playerId)
        })
        self.listenerKeys[listenerKey.key] = listenerKey
        return GameListenerKey(key: listenerKey.key)
    }
    
    func addPlayerTaggedListener(callback: @escaping (String, Location?) -> ()) -> GameListenerKey {
        let listenerKey = self.point.addListener(for: "playerTagged", callback: {(data) in
            let dataAsDict = data as! [String:Any]
            let playerId = dataAsDict["playerId"] as! String
            var flagHeldLocation: Location? = nil
            if let flagHeldLocationDict = dataAsDict["flagHeldLocation"] {
                do {
                    flagHeldLocation = try self.mapToObject(dictToMap: flagHeldLocationDict as! [String: Any], type: Location.self)
                } catch {
                    print(error)
                }
            }
            callback(playerId, flagHeldLocation)
        })
        self.listenerKeys[listenerKey.key] = listenerKey
        return GameListenerKey(key: listenerKey.key)
    }
    
    func addFlagPickedUpListener(callback: @escaping (String, String) -> ()) -> GameListenerKey {
        let listenerKey = self.point.addListener(for: "flagPickedUp", callback: {(data) in
            let dataAsDict = data as! [String:String]
            callback(dataAsDict["flagId"]!, dataAsDict["playerId"]!)
        })
        self.listenerKeys[listenerKey.key] = listenerKey
        return GameListenerKey(key: listenerKey.key)
    }
    
    func addGameStateChangedListener(callback: @escaping (Int) -> ()) -> GameListenerKey {
        let listenerKey = self.point.addListener(for: "gameStateChanged", callback: {(gameState) in
            callback(gameState as! Int)
        })
        self.listenerKeys[listenerKey.key] = listenerKey
        return GameListenerKey(key: listenerKey.key)
    }
    
    func addFlagAddedListener(callback: @escaping (Flag, Int) -> ()) -> GameListenerKey {
        let listenerKey = self.point.addListener(for: "flagAdded", callback: {(data) in
            let dataAsDict = data as! [String : Any]
            let teamIdOfFlag = dataAsDict["teamId"] as! Int
            let flagAsDict = dataAsDict["flag"] as! [String : Any]
            do {
                let flag = try self.mapToObject(dictToMap: flagAsDict, type: Flag.self)
                callback(flag, teamIdOfFlag)
            } catch {
                print(error)
            }
        })
        return GameListenerKey(key: listenerKey.key)
    }
    
    func updateLocation(latitude: String, longitude: String) {
        let dataToSend = [
            "latitude" : latitude,
            "longitude" : longitude
        ]
        self.point.sendMessage(command: "updateLocation", payLoad: dataToSend, callback: nil)
    }
    
    func createGame(key: String, gameName: String, callback: @escaping (GameError?) -> ()) {
        let dataToSend = [
            "key" : key,
            "gameName" : gameName
        ]
        self.point.sendMessage(command: "createGame", payLoad: dataToSend, callback: {(data, error) in
            if error != nil {
                print(error!.description)
                callback(GameError.serverError)
                return
            }
            let dataAsDict = data as! [String: Any]
            if !dataAsDict.isEmpty {
                let appError = dataAsDict["error"] as! String
                callback(GameError(rawValue: appError))
            } else {
                callback(nil)
            }
        })
    }
    
    func joinGame(key: String, playerName: String, callback: @escaping (GameError?) -> ()) {
        let dataToSend = [
            "key" : key,
            "playerName" : playerName
        ]
        self.point.sendMessage(command: "joinGame", payLoad: dataToSend, callback: {(data, error) in
            if error != nil {
                print(error!.description)
                callback(GameError.serverError)
                return
            }
            let dataAsDict = data as! [String:Any]
            if !dataAsDict.isEmpty {
                let appError = dataAsDict["error"] as! String
                callback(GameError(rawValue: appError))
            } else {
                callback(nil)
            }
        })
    }
    
    func createFlag(latitude: String, longitude: String, callback: @escaping (GameError?) -> ()) {
        let dataToSend = [
            "latitude" : latitude,
            "longitude" : longitude
        ]
        self.point.sendMessage(command: "createFlag", payLoad: dataToSend, callback: {(data, error) in
            if error != nil {
                print(error!.description)
                callback(GameError.serverError)
                return
            }
            let dataAsDict = data as! [String:String]
            if let appError = dataAsDict["error"] {
                callback(GameError(rawValue: appError)!)
            } else {
                callback(nil)
            }
        })
    }
    
    func tagPlayer(id: String,  callback: @escaping (GameError?) -> ()) {
        let dataToSend = [
            "playerToTagId" : id
        ]
        self.point.sendMessage(command: "tagPlayer", payLoad: dataToSend, callback: {(data, error) in
            if error != nil {
                print(error!.description)
                callback(GameError.serverError)
                return
            }
            let dataAsDict = data as! [String:String]
            if let appError = dataAsDict["error"] {
                callback(GameError(rawValue: appError))
                print("Error in tagplayer \(GameError(rawValue: appError))")
            } else {
                callback(nil)
            }
        })
        
    }
    
    func getFlags(callback: @escaping (Array<Flag>?, GameError?) -> ()) {
        self.point.sendMessage(command: "getFlags", payLoad: nil, callback: {(data, error) in
            if error != nil {
                print(error!.description)
                callback(nil, GameError.serverError)
                return
            }
            let dataAsDict = data as! [String:Any]
            if let appError = dataAsDict["error"] {
                let errorString = appError as! String
                callback(nil, GameError(rawValue: errorString))
            } else {
                let flagsFromDict = dataAsDict["flags"]! as! [String: Dictionary<String, Any>]
                var flags = [Flag]()
                for (_, flagDict) in flagsFromDict {
                    do {
                        let flag = try self.mapToObject(dictToMap: flagDict, type: Flag.self)
                        flags.append(flag)
                    } catch {
                        print(error)
                    }
                }
                callback(flags, nil)
            }
        })
    }
    
    func getGameState(callback: @escaping (Int?, GameError?) -> ()) {
        //print("GET GAME STATE IS BEING CALLED")
        self.point.sendMessage(command: "getGameState", payLoad: nil, callback: {(data, error) in
            //print("THIS CALLBACK IS BEING CALLED")
            if error != nil  {
                print(error!.description)
                callback(nil, GameError.serverError)
                return
            }
            let dataAsDict = data as! [String:Any]
            if let errorFromData = dataAsDict["error"] {
                let appError = errorFromData as! String
                callback(nil, GameError(rawValue: appError))
            } else {
                let gameState = dataAsDict["gameState"] as! Int
                callback(gameState, nil)
            }
        })
        
    }
    
    func getPlayerGameInfo(callback: @escaping (Player?, GameError?) -> ()) {
        self.point.sendMessage(command: "getPlayerInfo", payLoad: nil, callback: {(data, error) in
            if error != nil {
                print(error!.description)
                callback(nil, GameError.serverError)
                return
            }
            let dataAsDict = data as! [String: Any]
            if let appError = dataAsDict["error"] {
                let errorString = appError as! String
                callback(nil, GameError(rawValue: errorString))
            } else {
                let playerDict = dataAsDict["player"] as! [String:Any]
                do {
                    let player = try self.mapToObject(dictToMap: playerDict, type: Player.self)
                    callback(player, nil)
                } catch {
                    print(error)
                }
            }
            
        })
    }
    
    func getPlayers(callback: @escaping(Array<Player>?, GameError?) -> ()) {
        self.point.sendMessage(command: "getPlayers", payLoad: nil, callback: {(data, error) in
            if error != nil {
                print(error!.description)
                callback(nil, GameError.serverError)
                return
            }
            let dataAsDict = data as! [String: Any]
            if let appError = dataAsDict["error"] {
                let errorString = appError as! String
                callback(nil, GameError(rawValue: errorString))
            } else {
                let playersDict = dataAsDict["players"] as! [String:Dictionary<String, Any>]
                var playersArray = [Player]()
                //print("THIS IS THE PLAYERS DICTIONARY: \(playersDict)")
                for (_, playerDict) in playersDict {
                    do {
                       let player = try self.mapToObject(dictToMap: playerDict, type: Player.self)
                        playersArray.append(player)
                    } catch {
                        print("This is being printed")
                        print(error)
                    }
                }
                print(playersArray)
                callback(playersArray, nil)
            }
        })
    }
    
    func getTeams(callback: @escaping (Array<Team>?, GameError?) -> ()) {
        self.point.sendMessage(command: "getTeams", payLoad: nil, callback: {(data, error) in
            if error != nil {
                print(error!.description)
                callback(nil, GameError.serverError)
                return
            }
            let dataAsDict = data as! [String: Any]
            if let appError = dataAsDict["error"] {
                let errorString = appError as! String
                callback(nil, GameError(rawValue: errorString))
            } else {
                let teamsDict = dataAsDict["teams"] as! [String:Dictionary<String, Any>]
                var teamsArray = [Team]()
                for (_, teamDict) in teamsDict {
                    do {
                        let team = try self.mapToObject(dictToMap: teamDict, type: Team.self)
                        teamsArray.append(team)
                    } catch {
                        print(error)
                    }
                }
                callback(teamsArray, nil)
            }
        })
    }
    
    func pickUpFlag(flagId: String, callback: @escaping (GameError?) -> ()) {
        let payLoad = [
            "flagId" : flagId
        ]
        self.point.sendMessage(command: "pickUpFlag", payLoad: payLoad, callback: {(data, error) in
            if error != nil {
                print(error!.description)
                callback(GameError.serverError)
                return
            }
            let dataAsDict = data as! [String: String]
            if let appError = dataAsDict["error"] {
                callback(GameError(rawValue: appError))
            } else {
                callback(nil)
            }
        })
    }
    
    func createTeam(teamName: String, callback: @escaping (GameError?) -> ()) {
        let payLoad = [
            "teamName" : teamName
        ]
        self.point.sendMessage(command: "createTeam", payLoad: payLoad, callback: {(data, error) in
            if error != nil {
                print(error!.description)
                callback(GameError.serverError)
                return
            }
            let dataAsDict = data as! [String:Any]
            if let appError = dataAsDict["error"] {
                let errorString = appError as! String
                callback(GameError(rawValue: errorString))
            } else {
                callback(nil)
            }
        })
    }
    
    func joinTeam(teamId: Int, callback: @escaping (GameError?) -> ()) {
        let payload = [
            "teamId" : teamId
        ]
        self.point.sendMessage(command: "joinTeam", payLoad: payload, callback: {(data, error) in
            if error != nil {
                print(error!.description)
                callback(GameError.serverError)
                return
            }
            let dataAsDict = data as! [String:Any]
            if let appError = dataAsDict["error"] {
                let errorString = appError as! String
                callback(GameError(rawValue: errorString))
            } else {
                callback(nil)
            }
        })
    }
    
    func nextGameState(callback: @escaping (GameError?) -> ()) {
        self.point.sendMessage(command: "nextGameState", payLoad: nil, callback: {(data, error) in
            if error != nil {
                print(error!)
                callback(GameError.serverError)
                return
            }
            let dataAsDict = data as! [String:Any]
            if dataAsDict.isEmpty {
                callback(nil)
            } else {
                let appError = dataAsDict["error"] as! String
                callback(GameError(rawValue: appError))
            }
        })
    }
    
    /*func getFlags(callback: @escaping ([String : Dictionary<String, Any>], String?) -> ()) {
        self.point.sendMessage(command: "getFlags", payLoad: nil, callback: {(data, error) in
            callback(data as! [String : Dictionary<String, String>], error)
        })
    }*/
    
    private func mapToObject<t: Decodable>(dictToMap: Dictionary<String, Any>, type: t.Type) throws -> t {
        var serializedData: Data
        do {
            serializedData = try JSONSerialization.data(withJSONObject: dictToMap, options: [])
        } catch {
            throw error
        }
        
        let jsonDecoder = JSONDecoder()
        do {
            return try jsonDecoder.decode(t.self, from: serializedData)
        } catch {
            throw error
        }
        
    }
}



