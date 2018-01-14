//
//  Player.swift
//  Rook
//
//  Created by Eric Romrell on 12/29/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class Player: Equatable, CustomStringConvertible {
	private struct Keys {
		static let name = "name"
		static let photoUrl = "photoUrl"
		static let cards = "cards"
	}
	
	static var currentPlayer: Player? {
		guard let user = Auth.auth().currentUser, let name = user.displayName else { return nil }
		return Player(id: user.uid, name: name, photoUrl: user.photoURL)
	}
	
	var id: String?
	var name: String?
	var photoUrl: URL?
	var cards: [RookCard]
	
	var description: String {
		return name ?? "Unknown"
	}
	
	convenience init(snapshot: DataSnapshot) {
		guard let dict = snapshot.value as? [String: Any] else { fatalError() }
		self.init(id: snapshot.key, dict: dict)
	}
	
	convenience init(id: String, dict: [String: Any]) {
		self.init(id: id, name: dict[Keys.name] as? String, photoUrl: URL(string: dict[Keys.photoUrl] as? String))
	}
	
	init(id: String?, name: String?, photoUrl: URL?) {
		self.id = id
		self.name = name
		self.photoUrl = photoUrl
		self.cards = []
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
		dict[Keys.cards] = cards.map({ $0.toDict() })
		return dict
	}
}
