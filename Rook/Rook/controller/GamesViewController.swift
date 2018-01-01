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

class GamesViewController: UITableViewController {
	
	//Private properties
	private var authUI: FUIAuth?
	private var me: Player?
	private var games = [Game]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupAuth()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? GameViewController,
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
		return cell
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		let game = games.remove(at: indexPath.row)
		tableView.deleteRows(at: [indexPath], with: .automatic)
		
		//Delete it from Firebase (so that is gets deleted from other devices)
		if let id = game.id {
			DB.gameRef(id: id).removeValue()
		}
	}
	
	//MARK: Listeners
	
	@IBAction func logoutTapped(_ sender: Any) {
		if me != nil {
			do {
				try Auth.auth().signOut()
			} catch { print("Error logging out") }
			loggedIn()
		} else {
			loggedOut()
		}
	}
	
	@IBAction func addTapped(_ sender: Any) {
		DB.gamesRef.childByAutoId().setValue(Game(name: "Test").toDict())
	}
	
	//MARK: Authentication
	
	private func setupAuth() {
		let auth = Auth.auth()
		auth.addStateDidChangeListener { (auth, user) in
			self.me = Player.currentPlayer
			if self.me != nil {
				self.loggedIn()
			} else {
				self.loggedOut()
			}
		}
		
		authUI = FUIAuth.defaultAuthUI()
		authUI?.providers = [FUIGoogleAuth()]
	}
	
	private func loggedIn() {
		self.navigationItem.leftBarButtonItem?.title = "Logout"
		loadGames()
	}
	
	private func loggedOut() {
		if let authUI = authUI {
			self.present(authUI.authViewController(), animated: true, completion: nil)
		}
		self.navigationItem.leftBarButtonItem?.title = "Login"
	}
	
	//MARK: Private functions
	
	private func loadGames() {
		//Listen for games getting added, removed, or updated
		DB.gamesRef.observe(.childAdded) { (snapshot) in
			self.games.append(Game(snapshot: snapshot))
			self.tableView.reloadData()
		}
		DB.gamesRef.observe(.childRemoved) { (snapshot) in
			self.games.remove { $0.id == snapshot.key }
		}
		DB.gamesRef.observe(.childChanged) { (snapshot) in
			if let index = self.games.index(where: { $0.id == snapshot.key }) {
				self.games[index] = Game(snapshot: snapshot)
				self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
			}
		}
	}
}
