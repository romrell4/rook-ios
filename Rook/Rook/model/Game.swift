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
	}
	
	//MARK: Public properties
	var id: String?
	var name: String?
	var players: [Player]
	var kitty = [RookCard]() //Not serialized when saved
	
	//MARK: Initialization
	
	convenience init(snapshot: DataSnapshot) {
		guard let dict = snapshot.value as? [String: Any] else {
			fatalError()
		}
		let playersDict = dict[Keys.players] as? [String: Any] ?? [:]
		let players = playersDict.map { (tuple) -> Player in
			if let dict = tuple.value as? [String: Any] {
				return Player(id: tuple.key, dict: dict)
			}
			fatalError("Invalid model")
		}
		self.init(id: snapshot.key, name: dict[Keys.name] as? String, players: players)
	}
	
	init(id: String? = nil, name: String?, players: [Player] = []) {
		self.id = id
		self.name = name
		self.players = players
	}
	
	//MARK: Public functions
	
	func join() -> Bool {
		if let me = Player.currentPlayer, let id = id {
			players.append(me)
			DB.joinGame(gameId: id, player: me)
			return true
		}
		return false
	}
	
	func leave() -> Bool {
		if let me = Player.currentPlayer, let playerId = me.id, let gameId = id {
			players.remove { $0 == me }
			DB.leaveGame(gameId: gameId, playerId: playerId)
			return true
		}
		return false
	}
	
	func deal() {
		var deck = createDeck()
		deck.shuffle()

		//This will use integer division, leaving the cards in the kitty for the end
		let cardsPerPlayer = (deck.count - MIN_KITTY_SIZE) / players.count
		
		//Deal each player the correct number of cards by popping them off the top of the deck
		players.forEach { $0.cards = (0 ..< cardsPerPlayer).map { _ in deck.removeFirst() }.sorted() }
		kitty = (0 ..< deck.count).map { _ in deck.removeFirst() }
	}
	
	func toDict() -> [String: Any] {
		guard let name = name else { return [:] }
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
