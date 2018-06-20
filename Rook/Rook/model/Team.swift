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
	
	var name: String
	var points: Int
	var players: [String]
	
	convenience init(players: [Player]) {
		self.init(name: players.reduce("", { $0 + (String(char: $1.name?.first) ?? "") }), points: 0, players: players.map { $0.id })
	}
	
	convenience init(dict: [String: Any]) {
		self.init(
			name: dict[Keys.name] as? String ?? "",
			points: dict[Keys.points] as? Int ?? 0,
			players: dict[Keys.players] as? [String] ?? []
		)
	}
	
	init(name: String, points: Int, players: [String]) {
		self.name = name
		self.points = points
		self.players = players
	}
	
	func toDict() -> [String: Any] {
		return [
			Keys.name: name,
			Keys.points: points,
			Keys.players: players
		]
	}
}
