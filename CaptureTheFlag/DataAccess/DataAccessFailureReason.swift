//
//  File.swift
//  CaptureTheFlag
//
//  Created by Ethan Abrams on 4/16/18.
//  Copyright © 2018 Joe Durand. All rights reserved.
//

import Foundation
enum DataAccessFailureReason: String {
    case invalidGameKey = "Invalid Game Key"
    case invalidPlayerId = "Invalid player id"
    case accessDenied = "Access Denied"
}
