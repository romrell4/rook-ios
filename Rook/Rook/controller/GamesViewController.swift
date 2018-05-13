//
//  GamesViewController.swift
//  Rook
//
//  Created by Eric Romrell on 12/31/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseDatabase

class GamesViewController: UITableViewController {
	
	//Private properties
	private var authUI: FUIAuth?
	private var games = [Game]()
	
	//Computed
	private var observing: Bool = false {
		didSet {
			//If the value changed
			if oldValue != observing {
				if observing {
					print("Listening for updates")
					//Listen for games getting added, removed, or updated
					DB.gamesRef.observe(.childAdded) { (snapshot) in
						self.games.append(Game(snapshot: snapshot))
						self.tableView.reloadData()
					}
					DB.gamesRef.observe(.childRemoved) { (snapshot) in
						self.games.remove { $0.id == snapshot.key }
						self.tableView.reloadData()
					}
					DB.gamesRef.observe(.childChanged) { (snapshot) in
						if let index = self.games.index(where: { $0.id == snapshot.key }) {
							self.games[index] = Game(snapshot: snapshot)
							self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
						}
					}
				} else {
					print("Not listening for updates")
					DB.gamesRef.removeAllObservers()
					games = []
				}
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupAuth()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		if Player.current != nil {
			observing = true
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		//Stop listening for updates
		observing = false
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let navVc = segue.destination as? UINavigationController,
			let vc = navVc.topViewController as? GameViewController,
			let cell = sender as? UITableViewCell,
			let indexPath = tableView.indexPath(for: cell) {
			
			vc.game = games[indexPath.row]
		}
	}
	
	//MARK: UITableViewController
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return games.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let game = games[indexPath.row]
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = game.name
		cell.detailTextLabel?.text = "\(game.players.count) player\(game.players.count != 1 ? "s" : "")"
		
		//If you're logged in and the game has spots open or you're already in the game, you can tap it
		if let me = Player.current, (game.players.count < MAX_PLAYERS || game.players.contains(me)) {
			cell.isUserInteractionEnabled = true
		} else {
			cell.isUserInteractionEnabled = false
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return games[indexPath.row].owner == Player.current?.id
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		let game = games.remove(at: indexPath.row)
		//Delete it from Firebase (so that is gets deleted from other devices)
		DB.gameRef(id: game.id).removeValue()
		tableView.deleteRows(at: [indexPath], with: .automatic)
	}
	
	//MARK: Listeners
	
	@IBAction func authButtonTapped(_ sender: Any) {
		if Player.current == nil {
			if let authUI = authUI {
				self.present(authUI.authViewController(), animated: true, completion: nil)
			}
		} else {
			do {
				try Auth.auth().signOut()
				games = []
				tableView.reloadData()
				self.navigationItem.leftBarButtonItem?.title = "Logout"
			} catch { print("Error logging out") }
		}
	}
	
	@IBAction func addTapped(_ sender: Any) {
		guard let ownerId = Player.current?.id else { return }
		let alert = UIAlertController(title: "Create a Game", message: nil, preferredStyle: .alert)
		alert.addTextField { (textField) in
			textField.autocapitalizationType = .words
			textField.autocorrectionType = .no
			textField.placeholder = "Name"
		}
		alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { (action) in
			if let name = alert.textFields?.first?.text, name != "" {
				DB.createGame(Game(name: name, owner: ownerId))
			}
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		present(alert, animated: true)
	}
	
	//MARK: Private functions
	
	private func setupAuth() {
		authUI = FUIAuth.defaultAuthUI()
		authUI?.providers = [FUIGoogleAuth()]

		let auth = Auth.auth()
		auth.addStateDidChangeListener { (auth, user) in
			if Player.current != nil {
				self.navigationItem.leftBarButtonItem?.title = "Logout"
				self.observing = true
			} else {
				if let authUI = self.authUI {
					self.present(authUI.authViewController(), animated: true, completion: nil)
				}
				self.observing = false
				self.navigationItem.leftBarButtonItem?.title = "Login"
			}
		}
	}
}
