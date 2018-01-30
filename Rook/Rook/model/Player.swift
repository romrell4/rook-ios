//
//  Player.swift
//  Rook
//
//  Created by Eric Romrell on 12/29/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

private var photoCache = [URL: UIImage]()

class Player: Equatable, CustomStringConvertible {
	
	private struct Keys {
		static let name = "name"
		static let photoUrl = "photoUrl"
		static let sortNum = "sortNum"
		static let cards = "cards"
		static let playedCard = "playedCard"
		static let bid = "bid"
		static let passed = "passed"
	}
	
	static var current: Player? {
		guard let user = Auth.auth().currentUser, let name = user.displayName else { return nil }
		return Player(id: user.uid, name: name, photoUrl: user.photoURL)
	}
	
	//MARK: Persistent properties
	var id: String
	var name: String?
	var photoUrl: URL?
	var sortNum: Int?
	var cards: [RookCard]
	var playedCard: RookCard?
	var bid: Int?
	var passed: Bool?
	
	//MARK: Computed properties
	var photo: UIImage? {
		if let photoUrl = photoUrl {
			if let image = photoCache[photoUrl] {
				return image
			} else if let image = UIImage(fromUrl: photoUrl) {
				print("Fetching \(name ?? "null") from \(photoUrl.absoluteString)")
				photoCache[photoUrl] = image
				return image
			}
		}
		return nil
	}
	
	var description: String {
		return name ?? "Unknown"
	}
	
	convenience init(id: String, dict: [String: Any]) {
		var playedCard: RookCard? = nil
		if let tmp = dict[Keys.playedCard] as? [String: Any] {
			playedCard = RookCard(dict: tmp)
		}
		self.init(
			id: id,
			name: dict[Keys.name] as? String,
			photoUrl: URL(string: dict[Keys.photoUrl] as? String),
			sortNum: dict[Keys.sortNum] as? Int,
			cards: (dict[Keys.cards] as? [[String: Any]] ?? []).map { RookCard(dict: $0) },
			playedCard: playedCard,
			bid: dict[Keys.bid] as? Int,
			passed: dict[Keys.passed] as? Bool
		)
	}
	
	init(id: String, name: String?, photoUrl: URL?, sortNum: Int? = nil, cards: [RookCard] = [], playedCard: RookCard? = nil, bid: Int? = nil, passed: Bool? = nil) {
		self.id = id
		self.name = name
		self.photoUrl = photoUrl
		self.sortNum = sortNum
		self.cards = cards
		self.playedCard = playedCard
		self.bid = bid
		self.passed = passed
	}
	
	//MARK: Equatable
	
	static func ==(lhs: Player, rhs: Player) -> Bool {
		return lhs.id == rhs.id
	}
	
	//MARK: Public functions
	
	func toDict() -> [String: Any] {
		var dict = [String: Any]()
		dict[Keys.name] = name
		dict[Keys.photoUrl] = photoUrl?.absoluteString
		dict[Keys.sortNum] = sortNum
		dict[Keys.cards] = cards.map { $0.toDict() }
		dict[Keys.playedCard] = playedCard?.toDict()
		dict[Keys.bid] = bid
		dict[Keys.passed] = passed
		return dict
	}
}
