//
//  GameLobbyCell.swift
//  CaptureTheFlag
//
//  Created by Ethan Abrams on 6/3/18.
//  Copyright © 2018 Joe Durand. All rights reserved.
//

import UIKit

class GameLobbyCell: UITableViewCell {
    
    
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var playerNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
        
    func setPlayerName(name: String) {
        self.playerNameLabel.text = name
    }
    
    func setTeam(teamName: String) {
        self.teamNameLabel.text = teamName
    }
    

}
