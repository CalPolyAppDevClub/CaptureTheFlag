//
//  Secret.swift
//  CaptureTheFlag
//
//  Created by Joe Durand on 3/11/18.
//  Copyright © 2018 Cal Poly App Dev. All rights reserved.
//

import Foundation

class Secret {
    
    static var GOOGLE_MAPS_API_KEY: String? //= <your key here>
    
    static func getGoogleMapsApiKey() -> String {
        if let key = GOOGLE_MAPS_API_KEY {
            return key
        } else {
            printError(missingValue: "GOOGLE_MAPS_API_KEY")
            return ""
        }
    }
    
    private static func printError(missingValue: String) {
        print("WARNING: " + missingValue + " was not provided. Define in the Secret.swift file.")
    }
}
