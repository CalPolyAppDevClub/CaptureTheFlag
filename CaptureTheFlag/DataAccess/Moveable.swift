//
//  Moveable.swift
//  CaptureTheFlag
//
//  Created by Ethan Abrams on 7/28/18.
//  Copyright © 2018 Joe Durand. All rights reserved.
//

import Foundation
protocol Moveable {
    var location: Location? {get set}
    var id: String {get}
    var name: String? {get set}
}

