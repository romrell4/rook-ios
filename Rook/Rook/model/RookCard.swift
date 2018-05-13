//
//  RookCard.swift
//  Rook
//
//  Created by Eric Romrell on 12/29/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit
import FirebaseDatabase

private let POINT_RANKS = [RookCard.Rank.rook, 5, 10, 14, 1]

class RookCard: Comparable, CustomStringConvertible {
	//MARK: Types
	private struct Keys {
		static let faceUp = "faceUp"
		static let suit = "suit"
		static let rank = "rank"
	}
	enum Suit: Int {
		case red, green, yellow, black, rook
		
		static func fromText(text: String) -> Suit {
			switch text.lowercased() {
				case "red"	  : return .red
				case "green"  : return .green
				case "yellow" : return .yellow
				case "black"  : return .black
				default		  : return .rook
			}
		}
		
		var text: String {
			switch self {
				case .red	 : return "RED"
				case .green	 : return "GREEN"
				case .yellow : return "YELLOW"
				case .black	 : return "BLACK"
				case .rook	 : return "ROOK"
			}
		}
		
		var color: UIColor {
			switch self {
				case .red	 : 	return .cardRed
				case .green  : 	return .cardGreen
				case .yellow : 	return .cardYellow
				case .black  : 	return .black
				case .rook	 : 	return .black
			}
		}
		
		static let suits: [Suit] = [.red, .green, .yellow, .black]
	}
	
	struct Rank {
		static let rook = 0
		static let min = 1
		static let max = 14
	}
	
	//MARK: Public Properties
	var isFaceUp = true
	var suit: Suit
	var rank: Int
	
	//MARK: Computed Properties
	var isKittyable: Bool {
		return !POINT_RANKS.contains(rank)
	}
	var description: String {
		return "\(suit.text) \(rank)"
	}
	
	//MARK: Initialization
	init() {
		self.suit = Suit.rook
		self.rank = Rank.rook
	}
	
	convenience init(dict: [String: Any]) {
		guard let suitText = dict[Keys.suit] as? String, let rank = dict[Keys.rank] as? Int else { fatalError() }
		self.init(suit: Suit.fromText(text: suitText), rank: rank)
	}
	
	init(suit: Suit, rank: Int) {
		self.suit = suit
		self.rank = rank
	}
	
	//MARK: Comparable
	
	static func <(lhs: RookCard, rhs: RookCard) -> Bool {
		if lhs.suit == rhs.suit {
			//Make the ones act like fifteens for sorting purposes
			let lRank = lhs.rank == 1 ? 15: lhs.rank
			let rRank = rhs.rank == 1 ? 15: rhs.rank
			return lRank < rRank
		}
		return lhs.suit.rawValue < rhs.suit.rawValue
	}
	
	static func ==(lhs: RookCard, rhs: RookCard) -> Bool {
		return lhs.suit == rhs.suit && lhs.rank == rhs.rank
	}
	
	//MARK: Public functions
	
	func toDict() -> [String: Any] {
		return [
			Keys.faceUp: isFaceUp,
			Keys.suit: suit.text,
			Keys.rank: rank
		]
	}
}
