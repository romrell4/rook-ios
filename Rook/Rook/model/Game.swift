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

let MAX_PLAYERS = 4
private let MIN_KITTY_SIZE = 2

class Game {
	private struct Keys {
		static let name = "name"
		static let owner = "owner"
		static let state = "state"
		static let players = "players"
		static let kitty = "kitty"
		static let bid = "bid"
		static let bidder = "bidder"
	}
	
	enum State: String {
		case waitingForPlayers
		case waitingForTeams
		case bidding
		case started
		
		var isPreGame: Bool {
			return [.waitingForPlayers, .waitingForTeams].contains(self)
		}
	}
	
	//MARK: Public properties
	var id: String
	var name: String
	var owner: String
	var state: State
	var players: [Player]
	var kitty: [RookCard]?
	var bid: Int?
	var bidder: String?
	
	//MARK: Initialization
	
	convenience init(snapshot: DataSnapshot) {
		guard let dict = snapshot.value as? [String: Any] else { fatalError() }
		self.init(id: snapshot.key, dict: dict)
	}
	
	convenience init(id: String, dict: [String: Any]) {
		let name = dict[Keys.name] as? String ?? ""
		let owner = dict[Keys.owner] as? String ?? ""
		let playersDict = dict[Keys.players] as? [String: Any] ?? [:]
		let players = playersDict.map { (tuple) -> Player in
			if let dict = tuple.value as? [String: Any] {
				return Player(id: tuple.key, dict: dict)
			}
			fatalError()
		}
		let state = State(rawValue: dict[Keys.state] as? String ?? "") ?? .waitingForPlayers
		let bid = dict[Keys.bid] as? Int
		let bidder = dict[Keys.bidder] as? String
		self.init(id: id, name: name, owner: owner, players: players, state: state, bid: bid, bidder: bidder)
	}
	
	init(id: String = "", name: String, owner: String, players: [Player] = [], state: State = .waitingForPlayers, bid: Int? = nil, bidder: String? = nil) {
		self.id = id
		self.name = name
		self.owner = owner
		self.players = players
		self.state = state
		self.bid = bid
		self.bidder = bidder
	}
	
	//MARK: Public functions
	
	func join() {
		if let me = Player.currentPlayer, !players.contains(me) {
			players.append(me)
			DB.joinGame(gameId: id, player: me)
		}
	}
	
	func leave() {
		if let me = Player.currentPlayer {
			players.remove { $0 == me }
			DB.leaveGame(gameId: id, playerId: me.id)
		}
	}
	
	func deal() {
		state = .bidding
		
		var deck = createDeck()
		deck.shuffle()

		//This will use integer division, leaving the cards in the kitty for the end
		let cardsPerPlayer = (deck.count - MIN_KITTY_SIZE) / players.count
		
		//Deal each player the correct number of cards by popping them off the top of the deck
		players.forEach { $0.cards = (0 ..< cardsPerPlayer).map { _ in deck.removeFirst() }.sorted() }
		kitty = (0 ..< deck.count).map { _ in deck.removeFirst() }
	}
	
	func toDict() -> [String: Any] {
		var dict: [String: Any] = [
			Keys.name: name,
			Keys.owner: owner,
			Keys.state: state.rawValue
		]
		var playersDict = [String: Any]()
		players.forEach { playersDict[$0.id] = $0.toDict() }
		dict[Keys.players] = playersDict
		
		dict[Keys.kitty] = kitty?.map { $0.toDict() }
		dict[Keys.bid] = bid
		dict[Keys.bidder] = bidder
		return dict
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
