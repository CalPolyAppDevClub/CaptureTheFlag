
import UIKit

class GameLobbyViewController: CaptureTheFlagViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var joinTeamButton2: UIButton!
    @IBOutlet weak var joinTeamButton1: UIButton!
    @IBOutlet weak var teamLabel2: UILabel!
    @IBOutlet weak var teamLabel1: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var teamNameText: UITextField!
    @IBOutlet weak var teamSuccess: UITextView!
    
    var players = Dictionary<String, Player>()
    var teams = Dictionary<Int, Team>()
    var listenerKeys = [GameListenerKey]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.serverAccess!.getPlayers(callback: {(players, error) in
            if error != nil {
                self.handleError(error!)
                return
            }
            for player in players! {
                self.players[player.id] = player
            }
            self.serverAccess!.getTeams(callback: {(teams, error) in
                if teams != nil {
                    for team in teams! {
                        self.teams[team.id] = team
                        if team.id == 1 {
                            self.teamLabel1.text = team.name
                        } else {
                            self.teamLabel2.text = team.name
                        }
                    }
                }
                self.tableView.reloadData()
            })
        })
        
        self.createListeners()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "playerCell", for: indexPath) as? GameLobbyCell  else {
            fatalError("")
        }
        let playersAsArray = Array(self.players.values)
        let player = playersAsArray[indexPath.row]
        cell.setPlayerName(name: player.name!)
        if !self.teams.isEmpty {
            if (self.teams[1]?.contians(playerId: player.id))! {
                cell.setTeam(teamName: self.teams[1]!.name)
            } else if self.teams[2] != nil && (self.teams[2]?.contians(playerId: player.id))!{
                cell.setTeam(teamName: self.teams[2]!.name)
                }
            }
        return cell
    }
    
    @IBAction func createTeam(_ sender: Any) {
        //print("create Team in being called")
        self.serverAccess!.createTeam(teamName: teamNameText.text!, callback: {(error) in
            if error != nil {
                self.handleError(error!)
            }
        })
    }
    
    @IBAction func joinTeam(_ sender: Any) {
        if sender as? UIButton == self.joinTeamButton1 {
            self.serverAccess!.joinTeam(teamId: 1, callback: {(error) in
                print(error)
            })
        }
        if sender as? UIButton == self.joinTeamButton2 {
            self.serverAccess!.joinTeam(teamId: 2, callback: {(error) in
                print(error)
            })
        }
        
    }
    
    @IBAction func startGame(_ sender: Any) {
        self.serverAccess?.nextGameState(callback: {(error) in
            if error != nil {
                self.handleError(error!)
                return
            }
        })
    }
    
    private func createListeners() {
        
        self.listenerKeys.append(
            self.serverAccess!.addTeamAddedListener(callback: {(team) in
                if self.teamLabel1.text == "" {
                    self.teamLabel1.text = team.name
                } else {
                    self.teamLabel2.text = team.name
                }
                
                self.teams[team.id] = team
            }))
        self.listenerKeys.append(
            self.serverAccess!.addPlayerAddedListener(callback: {(player) in
                self.players[player.id] = player
                self.tableView.reloadData()
        }))
        
        self.listenerKeys.append(
            self.serverAccess!.addPlayerRemovedListener(callback: {(playerId) in
                self.players.removeValue(forKey: playerId)
                //print("Player removed listener being called")
                self.tableView.reloadData()
        }))
        self.listenerKeys.append(
            self.serverAccess!.addPlayerJoinedTeamListener(callback: {(playerId, teamId) in
                self.teams[teamId]?.addPlayer(id: playerId)
                self.tableView.reloadData()
        }))
        
        self.listenerKeys.append(
            self.serverAccess!.addGameStateChangedListener(callback: {(gameState) in
                if gameState == 1 {
                    self.removeListeners()
                    self.performSegue(withIdentifier: "toMapView", sender: nil)
                } else {
                    //TODO go to something went wrong view controller
                }
            }))
    }
    
    private func removeListeners() {
        for listener in self.listenerKeys {
            self.serverAccess?.removeListener(listener)
        }
    }
    
    private func handleError(_ error: GameError) {
        switch error {
        case GameError.tooManyTeams:
            self.teamSuccess.text = "Cannot create another team"
        case GameError.tooManyPlayersOnTeam:
            self.teamSuccess.text = "Cannot join team: player limit reached"
        default:
            print(error)
            return
        }
    }
    
}




