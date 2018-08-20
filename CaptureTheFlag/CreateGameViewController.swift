//
//  CreateGameViewController.swift
//  CaptureTheFlag
//
//  Created by Ethan Abrams on 6/2/18.
//  Copyright © 2018 Joe Durand. All rights reserved.
//

import UIKit

class CreateGameViewController: CaptureTheFlagViewController {
    
    @IBOutlet weak var gameKeyText: UITextField!
    @IBOutlet weak var playerNameText: UITextField!
    @IBOutlet weak var gameNameText: UITextField!
    @IBOutlet weak var success: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createGame(_ sender: Any) {
        if gameKeyText.text != nil && playerNameText.text != nil && gameNameText != nil {
            self.serverAccess!.createGame(key: gameKeyText.text!, gameName: gameNameText.text!, callback: {(error) in
                if error != nil {
                    self.handleError(error!)
                } else {
                    self.serverAccess!.joinGame(key: self.gameKeyText.text!, playerName: self.playerNameText.text!, callback: {(error) in
                        if error != nil {
                            
                        } else {
                            self.performSegue(withIdentifier: "toLobbyView", sender: nil)
                        }
                    })
                }
            })
        }
    }
    
    private func handleError(_ error: GameError) {
        switch error {
        case GameError.serverError:
            break
            //segue to error viewcontroller
        default:
            break
        }
    }
    
}
