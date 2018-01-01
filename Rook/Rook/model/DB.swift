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
		static let players = "players"
	}
	
	static var ref: DatabaseReference!
	
	//MARK: Games object
	static var gamesRef: DatabaseReference {
		return ref.child(Keys.games)
	}
	static func gameRef(id: String) -> DatabaseReference {
		return gamesRef.child(id)
	}
	static func playersRef(gameId: String) -> DatabaseReference {
		return gameRef(id: gameId).child(Keys.gamePlayers)
	}
	static func playerRef(gameId: String, playerId: String) -> DatabaseReference {
		return playersRef(gameId: gameId).child(playerId)
	}
	static func joinGame(gameId: String, player: Player) {
		if let playerId = player.id {
			playerRef(gameId: gameId, playerId: playerId).setValue(player.toDict())
		}
	}
	static func leaveGame(gameId: String, playerId: String) {
		playerRef(gameId: gameId, playerId: playerId).removeValue()
	}
	
	
	//MARK: Players object
	static var playersRef: DatabaseReference {
		return ref.child(Keys.players)
	}
	static func playerRef(id: String) -> DatabaseReference {
		return playersRef.child(id)
	}
	static func saveMe() {
		
	}
}
