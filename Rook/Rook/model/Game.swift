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
let MIN_BID = 50
private let MIN_KITTY_SIZE = 2

class Game {
	private struct Keys {
		static let name = "name"
		static let owner = "owner"
		static let state = "state"
		static let players = "players"
		static let kitty = "kitty"
		static let currentBidder = "currentBidder"
		static let trumpSuit = "trumpSuit"
	}
	
	enum State: String {
		case waitingForPlayers
		case waitingForTeams
		case bidding
		case kitty
		case declareTrump
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
	var currentBidder: String?
	var trumpSuit: RookCard.Suit?
	
	//MARK: Computed properties
	var me: Player? {
		return players.first { $0 == Player.current }
	}
	var highBidder: Player? {
		return players.filter { $0.bid != nil }.max { $0.bid! < $1.bid! }
	}
	
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
		let kitty = (dict[Keys.kitty] as? [[String: Any]])?.map { RookCard(dict: $0) }
		let state = State(rawValue: dict[Keys.state] as? String ?? "") ?? .waitingForPlayers
		let currentBidder = dict[Keys.currentBidder] as? String
		var trumpSuit: RookCard.Suit?
		if let trumpSuitText = dict[Keys.trumpSuit] as? String {
			trumpSuit = RookCard.Suit.fromText(text: trumpSuitText)
		}
		self.init(id: id, name: name, owner: owner, state: state, players: players, kitty: kitty, currentBidder: currentBidder, trumpSuit: trumpSuit)
	}
	
	init(id: String = "", name: String, owner: String, state: State = .waitingForPlayers, players: [Player] = [], kitty: [RookCard]? = nil, currentBidder: String? = nil, trumpSuit: RookCard.Suit? = nil) {
		self.id = id
		self.name = name
		self.owner = owner
		
		//Sort the players in their turn order (if available)
		let me = players.first { $0 == Player.current }
		self.players = players.sorted { (p1, p2) in
			if let s1 = p1.sortNum, let s2 = p2.sortNum, let mySort = me?.sortNum {
				return (s1 + mySort) % MAX_PLAYERS < (s2 + mySort) % MAX_PLAYERS
			}
			return false
		}
		
		self.kitty = kitty
		self.state = state
		self.currentBidder = currentBidder
		self.trumpSuit = trumpSuit
	}
	
	//MARK: Public functions
	
	func join() {
		if let me = Player.current, !players.contains(me) {
			players.append(me)
			DB.joinGame(gameId: id, player: me)
		}
	}
	
	func leave() {
		if let me = Player.current {
			players.remove { $0 == me }
			DB.leaveGame(gameId: id, playerId: me.id)
		}
	}
	
	func deal() {
		state = .bidding
		currentBidder = owner
		
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
		dict[Keys.currentBidder] = currentBidder
		dict[Keys.trumpSuit] = trumpSuit?.text
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
