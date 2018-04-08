//
//  CaptureTheFlagViewController.swift
//  CaptureTheFlag
//
//  Created by Ethan Abrams on 3/11/18.
//  Copyright © 2018 Joe Durand. All rights reserved.
//

import UIKit
import CoreLocation

class CaptureTheFlagViewController: UIViewController {
    var gameAccess: GameAccess!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextViewController = segue.destination as? CaptureTheFlagViewController {
            nextViewController.gameAccess = self.gameAccess
        }
    }

}
