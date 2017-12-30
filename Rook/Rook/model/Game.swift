//
//  Game.swift
//  Rook
//
//  Created by Eric Romrell on 12/29/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import Foundation

private let MIN_KITTY_SIZE = 2

class Game {
	static var instance = Game()
	
	var players = [Player]()
	var kitty = [RookCard]()
	
	//MARK: Initialization
	
	private init() {
		createPlayers()
	}
	
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
	
	private func createPlayers() {
		players = (1 ... 4).map { Player(name: "Player \($0)") }
	}
	
	//MARK: Public functions
	
	func deal() {
		var deck = createDeck()
		deck.shuffle()

		//This will use integer division, leaving the cards in the kitty for the end
		let cardsPerPlayer = (deck.count - MIN_KITTY_SIZE) / players.count
		
		//Deal each player the correct number of cards by popping them off the top of the deck
		players.forEach { $0.cards = (0 ..< cardsPerPlayer).map { _ in deck.removeFirst() }.sorted() }
		kitty = (0 ..< deck.count).map { _ in deck.removeFirst() }
	}
}
