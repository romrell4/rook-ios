//
//  Game.swift
//  Rook
//
//  Created by Eric Romrell on 12/29/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

private let MIN_KITTY_SIZE = 2

class Game {
	private struct Keys {
		static let name = "name"
		static let players = "players"
		static let started = "started"
	}
	
	//MARK: Public properties
	var id: String
	var name: String
	var players: [Player]
	var started: Bool
	var kitty = [RookCard]() //Not serialized when saved
	
	//MARK: Initialization
	
	convenience init(snapshot: DataSnapshot) {
		guard let dict = snapshot.value as? [String: Any] else {
			fatalError()
		}
		self.init(id: snapshot.key, dict: dict)
	}
	
	convenience init(id: String, dict: [String: Any]) {
		let name = dict[Keys.name] as? String ?? ""
		let playersDict = dict[Keys.players] as? [String: Any] ?? [:]
		let players = playersDict.map { (tuple) -> Player in
			if let dict = tuple.value as? [String: Any] {
				return Player(id: tuple.key, dict: dict)
			}
			fatalError()
		}
		let started = dict[Keys.started] as? Bool ?? false
		self.init(id: id, name: name, players: players, started: started)
	}
	
	init(id: String, name: String, players: [Player] = [], started: Bool = false) {
		self.id = id
		self.name = name
		self.players = players
		self.started = started
	}
	
	//MARK: Public functions
	
	func join() {
		if let me = Player.currentPlayer, !players.contains(me) {
			players.append(me)
			DB.joinGame(gameId: id, player: me)
		}
	}
	
	func leave() {
		if let me = Player.currentPlayer, let playerId = me.id {
			players.remove { $0 == me }
			DB.leaveGame(gameId: id, playerId: playerId)
		}
	}
	
	func deal() {
		started = true
		
		var deck = createDeck()
		deck.shuffle()

		//This will use integer division, leaving the cards in the kitty for the end
		let cardsPerPlayer = (deck.count - MIN_KITTY_SIZE) / players.count
		
		//Deal each player the correct number of cards by popping them off the top of the deck
		players.forEach { $0.cards = (0 ..< cardsPerPlayer).map { _ in deck.removeFirst() }.sorted() }
		kitty = (0 ..< deck.count).map { _ in deck.removeFirst() }
	}
	
	func toDict() -> [String: Any] {
		return [
			Keys.name: name,
			Keys.players: players.map({ return $0.toDict() })
		]
	}
	
	//MARK: Private functions
	
	private func createDeck() -> [RookCard] {
		//Add the rook card first
		var deck = [RookCard()]
		
		for rank in RookCard.Rank.min ... RookCard.Rank.max {
			for suit in RookCard.Suit.suits {
				deck.append(RookCard(suit: suit, rank: rank))
			}
		}
		return deck
	}
}
