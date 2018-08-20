//
//  LoginViewController.swift
//  CaptureTheFlag
//
//  Created by Ethan Abrams on 8/19/18.
//  Copyright © 2018 Joe Durand. All rights reserved.
//

import UIKit

class LoginViewController: CaptureTheFlagViewController {
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(_ sender: Any) {
        print("pressed the login button")
        if usernameText.text != nil && passwordText.text != nil {
            self.serverAccess?.initaiteConnection(username: usernameText.text!, password: passwordText.text!, callback: {(error) in
                if error != nil {
                    print(error?.rawValue)
                } else {
                    self.performSegue(withIdentifier: "backToMainSegue", sender: nil)
                }
            })
        }
    }
}
