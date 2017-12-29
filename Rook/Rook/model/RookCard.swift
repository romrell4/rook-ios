//
//  RookCard.swift
//  Rook
//
//  Created by Eric Romrell on 12/29/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class RookCard {
	
	// MARK: - Nested types
	
	enum Suit : String {
		case rook, red, green, yellow, black
		
		var text: String {
			return self.rawValue.uppercased()
		}
		
		var color: UIColor {
			switch self {
				case .red	: 	return UIColor(r: 237, g:  37, b:  50)
				case .green : 	return UIColor(r:  36, g: 193, b:  80)
				case .yellow: 	return UIColor(r: 242, g: 199, b:  58)
				case .black : 	return .black
				default		: 	return .black
			}
		}
		
		static let validSuits: [Suit] = [.rook, .red, .green, .yellow, .black]
	}
	
	struct Rank {
		static let rook = 0
		static let min = 1
		static let max = 14
	}
	
	// MARK: - Properties
	
	var isFaceUp = false
	var suit: Suit
	var rank: Int
	
	// MARK: - Initialization
	
	init() {
		// By default this builds a Rook card
		self.suit = Suit.rook
		self.rank = Rank.rook
	}
	
	init(suit: Suit, rank: Int) {
		self.suit = suit
		self.rank = rank
	}
}
