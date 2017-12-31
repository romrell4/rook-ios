//
//  Player.swift
//  Rook
//
//  Created by Eric Romrell on 12/29/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import Foundation

class Player: Equatable, CustomStringConvertible {
	var id: Int
	var name: String
	var cards: [RookCard]
	
	var description: String {
		return name
	}
	
	init(id: Int, name: String) {
		self.id = id
		self.name = name
		self.cards = []
	}
	
	//MARK: Equatable
	
	static func ==(lhs: Player, rhs: Player) -> Bool {
		return lhs.id == rhs.id
	}
}
