//
//  ViewController.swift
//  CaptureTheFlag
//
//  Created by Joe Durand on 2/15/18.
//  Copyright © 2018 Joe Durand. All rights reserved.
//

import UIKit
import GoogleSignIn
class ViewController: CaptureTheFlagViewController, GIDSignInUIDelegate  {

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        let googleButton = GIDSignInButton()
        view.addSubview(googleButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    


}

