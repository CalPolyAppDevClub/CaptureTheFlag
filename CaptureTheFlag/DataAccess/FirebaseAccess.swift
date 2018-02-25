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
    var ref: DatabaseReference!
    ref = Database.database().reference()
    
    init() {
        
    }
    
    func createGame(id: String, name: String) {
        
    }
    
}
