//
//  DB.swift
//  Rook
//
//  Created by Eric Romrell on 12/31/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DB {
	private struct Keys {
		static let games = "games"
		static let gamePlayers = "players"
		static let users = "users"
		static let logs = "logs"
	}
	
	static var ref: DatabaseReference!
	
	//MARK: Games object
	static var gamesRef: DatabaseReference { return ref.child(Keys.games) }
	static func gameRef(id: String) -> DatabaseReference { return gamesRef.child(id) }
	static func playersRef(gameId: String) -> DatabaseReference { return gameRef(id: gameId).child(Keys.gamePlayers) }
	static func playerRef(gameId: String, playerId: String) -> DatabaseReference { return playersRef(gameId: gameId).child(playerId) }
	
	static var usersRef: DatabaseReference { return ref.child(Keys.users) }
	
	//MARK: Actions
	static func createGame(_ game: Game) {
		gamesRef.childByAutoId().setValue(game.toDict())
	}
	static func createUser(_ player: Player) {
		usersRef.child(player.id).setValue(player.toDict())
	}
	static func updateGame(_ game: Game) {
		gameRef(id: game.id).setValue(game.toDict())
	}
	static func log(_ message: String) {
		ref.child(Keys.logs).childByAutoId().setValue(message)
	}
}
