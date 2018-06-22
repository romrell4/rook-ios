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
//TODO: Make it so that if you take all the cards, you get a 200 instead of 180
let MAX_POINTS = 200
private let MIN_KITTY_SIZE = 2

class Game {
	private struct Keys {
		static let name = "name"
		static let owner = "owner"
		static let state = "state"
		static let players = "players"
		static let teams = "teams"
		static let hands = "hands"
		static let kitty = "kitty"
		static let bidTurn = "bidTurn"
		static let turn = "turn"
	}
	
	enum State: String {
		case waitingForPlayers
		case waitingForTeams
		case bidding
		case viewKitty
		case discardAndDeclareTrump
		case started
		
		var isPreGame: Bool {
			return [.waitingForPlayers, .waitingForTeams].contains(self)
		}
		
		func getAlertClass(inGame game: Game) -> GameAlertView.Type? {
			switch self {
				case .waitingForPlayers, .waitingForTeams:	return PreGameAlertView.self
				case .bidding: 								return BiddingAlertView.self
				case .viewKitty: 							return game.currentHand?.bidWinner == game.me?.id ? KittyAlertView.self : nil
				case .discardAndDeclareTrump:				return game.currentHand?.bidWinner == game.me?.id ? TrumpColorAlertView.self : nil
				default: 									return nil
			}
		}
	}
	
	//MARK: Public properties
	var id: String
	var name: String
	var owner: String
	var state: State
	var players: [Player]
	var teams: [Team]
	var hands: [Hand]
	var kitty: [RookCard]?
	var bidTurn: String?
	var turn: String?
	
	//MARK: Computed properties
	var me: Player? { return players.first { $0 == Player.current } }
	var currentHand: Hand? { return hands.last }
	var otherPlayers: [Player] { return players.filter { $0 != me } }
	
	//MARK: Initialization
	
	convenience init(snapshot: DataSnapshot) {
		guard let dict = snapshot.value as? [String: Any] else { fatalError() }
		self.init(id: snapshot.key, dict: dict)
	}
	
	convenience init(id: String, dict: [String: Any]) {
		let name = dict[Keys.name] as? String ?? ""
		let owner = dict[Keys.owner] as? String ?? ""
		let playersDict = dict[Keys.players] as? [String: Any] ?? [:]
		let players = playersDict.map { Player(id: $0.key, dict: $0.value as? [String: Any] ?? [:]) }
		let teamsDict = dict[Keys.teams] as? [String: Any] ?? [:]
		let teams = teamsDict.map { Team(id: $0.key, dict: $0.value as? [String: Any] ?? [:]) }
		let hands = (dict[Keys.hands] as? [[String: Any]])?.map { Hand(dict: $0) } ?? []
		let kitty = (dict[Keys.kitty] as? [[String: Any]])?.map { RookCard(dict: $0) }
		let state = State(rawValue: dict[Keys.state] as? String ?? "") ?? .waitingForPlayers
		let turn = dict[Keys.turn] as? String
		self.init(id: id, name: name, owner: owner, state: state, players: players, teams: teams, hands: hands, kitty: kitty, turn: turn)
	}
	
	init(id: String = "", name: String, owner: String, state: State = .waitingForPlayers, players: [Player] = [], teams: [Team] = [], hands: [Hand] = [], kitty: [RookCard]? = nil, turn: String? = nil) {
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
		
		self.teams = teams
		self.hands = hands
		self.kitty = kitty
		self.state = state
		self.turn = turn
	}
	
	//MARK: Public functions
	
	func join() {
		if let me = Player.current, !players.contains(me) {
			players.append(me)
			DB.updateGame(self)
		}
	}
	
	func deal() {
		state = .bidding
		hands.append(Hand(points: [teams[0].id: 0, teams[1].id: 0]))
		
		//TODO: Start with the correct person
		turn = owner
		
		var deck = createDeck()
		deck.shuffle()

		//This will use integer division, leaving the cards in the kitty for the end
		let cardsPerPlayer = (deck.count - MIN_KITTY_SIZE) / players.count
		
		//Deal each player the correct number of cards by popping them off the top of the deck
		players.forEach { $0.cards = (0 ..< cardsPerPlayer).map { _ in deck.removeFirst() }.sorted() }
		kitty = (0 ..< deck.count).map { _ in deck.removeFirst() }
		
		//TODO: Handle misdeal
	}
	
	func endHand() {
		//Add the points from the hand into the teams
		if let bid = currentHand?.bid,
			let bidWinner = currentHand?.bidWinner,
			let points = currentHand?.points,
			let biddingTeam = teams.first(where: { $0.players.contains(bidWinner) }),
			let otherTeam = teams.first(where: { $0.id != biddingTeam.id }),
			let biddingTeamHandPoints = points[biddingTeam.id] {
			
			//TODO: Deal with 200 hands
			//Either add the points they earned, or subtract the bid
			biddingTeam.points += biddingTeamHandPoints >= bid ? biddingTeamHandPoints : -bid
			otherTeam.points += points[otherTeam.id] ?? 0
		}

		//Reset any player data from the previous round
		players.forEach {
			$0.bid = nil
			$0.passed = nil
		}
		
		deal()
		//TODO: Fix not drawing other player's cards or bidding screen
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
		
		var teamsDict = [String: Any]()
		teams.forEach { teamsDict[$0.id] = $0.toDict() }
		dict[Keys.teams] = teamsDict
		
		dict[Keys.hands] = hands.map { $0.toDict() }
		dict[Keys.kitty] = kitty?.map { $0.toDict() }
		dict[Keys.turn] = turn
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
