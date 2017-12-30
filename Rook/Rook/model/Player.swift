//
//  Player.swift
//  Rook
//
//  Created by Eric Romrell on 12/29/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import Foundation

class Player {
	var name: String
	var cards: [RookCard]
	
	init(name: String) {
		self.name = name
		self.cards = []
	}
}
