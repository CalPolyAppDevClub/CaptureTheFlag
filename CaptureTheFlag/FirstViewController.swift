//
//  FirstViewController.swift
//  CaptureTheFlag
//
//  Created by Ethan Abrams on 6/9/18.
//  Copyright © 2018 Joe Durand. All rights reserved.
//

import UIKit

class FirstViewController: CaptureTheFlagViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
    @IBAction func login(_ sender: Any) {
        setUPWSRR()
    }
    
    @IBAction func JoinGame(_ sender: Any) {
        setUPWSRR()
    }
    
    @IBAction func CreateGame(_ sender: Any) {
        setUPWSRR()
    }
    
    
    private func setUPWSRR() {
        let RRManager = WebSocketRequestResponse()
        self.serverAccess = ServerAccess(requestResponse: RRManager)
    }
    
    deinit {
        print("The first view controller deinit ")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
