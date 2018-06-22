//
//  Hand.swift
//  Rook
//
//  Created by Eric Romrell on 6/7/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import Foundation

class Hand {
	private struct Keys {
		static var points = "points"
		static var bid = "bid"
		static var bidWinner = "bidWinner"
		static var trumpSuit = "trumpSuit"
	}
	
	var points: [String: Int]
	var bid: Int?
	var bidWinner: String?
	var trumpSuit: RookCard.Suit?
	
	convenience init(dict: [String: Any]) {
		let points = dict[Keys.points] as? [String: Int] ?? [:]
		let bid = dict[Keys.bid] as? Int
		let bidWinner = dict[Keys.bidWinner] as? String
		var trumpSuit: RookCard.Suit?
		if let trumpSuitText = dict[Keys.trumpSuit] as? String {
			trumpSuit = RookCard.Suit.fromText(text: trumpSuitText)
		}
		self.init(points: points, bid: bid, bidWinner: bidWinner, trumpSuit: trumpSuit)
	}
	
	init(points: [String: Int], bid: Int? = nil, bidWinner: String? = nil, trumpSuit: RookCard.Suit? = nil) {
		self.points = points
		self.bid = bid
		self.bidWinner = bidWinner
		self.trumpSuit = trumpSuit
	}
	
	func toDict() -> [String: Any] {
		var dict = [String: Any]()
		dict[Keys.points] = points
		dict[Keys.bid] = bid
		dict[Keys.bidWinner] = bidWinner
		dict[Keys.trumpSuit] = trumpSuit?.text
		return dict
	}
}
