//
//  Team.swift
//  Rook
//
//  Created by Eric Romrell on 6/4/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import Foundation

class Team {
	private struct Keys {
		static let teamNumber = "teamNumber"
		static let gamePoints = "gamePoints"
		static let handPoints = "handPoints"
	}
	
	//Properties
	var teamNumber: Int
	var gamePoints: Int
	var handPoints: Int
	
	convenience init(dict: [String: Any] = [:]) {
		self.init(
			teamNumber: dict[Keys.teamNumber] as? Int ?? 0,
			gamePoints: dict[Keys.gamePoints] as? Int,
			handPoints: dict[Keys.handPoints] as? Int
		)
	}
	
	init(teamNumber: Int, gamePoints: Int? = 0, handPoints: Int? = 0) {
		self.teamNumber = teamNumber
		self.gamePoints = gamePoints ?? 0
		self.handPoints = handPoints ?? 0
	}
	
	func toDict() -> [String: Any] {
		return [
			Keys.teamNumber: teamNumber,
			Keys.gamePoints: gamePoints,
			Keys.handPoints: handPoints
		]
	}
}
