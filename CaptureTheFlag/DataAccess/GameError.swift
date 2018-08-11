//
//  GameError.swift
//  CaptureTheFlag
//
//  Created by Ethan Abrams on 6/24/18.
//  Copyright © 2018 Joe Durand. All rights reserved.
//

import Foundation


enum GameError: String {
    case incorrectGameState = "incorrectGameState"
    case playerAlreadyInGame = "playerAlreadyInGame"
    case playersNotCloseEnough = "playersNotCloseEnough"
    case tagReceiverNotInGame = "tagReceiverNotInGame"
    case serverError = "serverError"
    case gameDoesNotExist = "gameDoesNotExist"
    case tooManyTeams = "tooManyTeams"
    case tooManyPlayersOnTeam = "tooManyPlayersOnTeam"
}
