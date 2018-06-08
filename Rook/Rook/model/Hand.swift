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
		static var biddingTeam = "biddingTeam"
		static var trumpSuit = "trumpSuit"
	}
	
	var points: [Int]
	var bid: Int?
	var biddingTeam: Int?
	var trumpSuit: RookCard.Suit?
	
	convenience init(dict: [String: Any]) {
		let points = dict[Keys.points] as? [Int] ?? []
		let bid = dict[Keys.bid] as? Int
		let biddingTeam = dict[Keys.biddingTeam] as? Int
		var trumpSuit: RookCard.Suit?
		if let trumpSuitText = dict[Keys.trumpSuit] as? String {
			trumpSuit = RookCard.Suit.fromText(text: trumpSuitText)
		}
		self.init(points: points, bid: bid, biddingTeam: biddingTeam, trumpSuit: trumpSuit)
	}
	
	init(points: [Int], bid: Int? = nil, biddingTeam: Int? = nil, trumpSuit: RookCard.Suit? = nil) {
		self.points = points
		self.bid = bid
		self.biddingTeam = biddingTeam
		self.trumpSuit = trumpSuit
	}
	
	func toDict() -> [String: Any] {
		var dict = [String: Any]()
		dict[Keys.points] = points
		dict[Keys.bid] = bid
		dict[Keys.biddingTeam] = biddingTeam
		dict[Keys.trumpSuit] = trumpSuit?.text
		return dict
	}
}
