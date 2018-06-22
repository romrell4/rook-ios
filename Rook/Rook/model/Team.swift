//
//  Team
//  Rook
//
//  Created by Eric Romrell on 6/19/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import Foundation

class Team {
	private struct Keys {
		static var name = "name"
		static var points = "points"
		static var players = "players"
	}
	
	var id: String
	var points: Int
	var players: [String]
	
	convenience init(players: [Player]) {
		self.init(
			id: players.reduce("", { $0 + $1.id }),
			points: 0,
			players: players.map { $0.id }
		)
	}
	
	convenience init(id: String, dict: [String: Any]) {
		self.init(
			id: id,
			points: dict[Keys.points] as? Int ?? 0,
			players: dict[Keys.players] as? [String] ?? []
		)
	}
	
	init(id: String, points: Int, players: [String]) {
		self.id = id
		self.points = points
		self.players = players
	}
	
	func toDict() -> [String: Any] {
		return [
			Keys.points: points,
			Keys.players: players
		]
	}
}
