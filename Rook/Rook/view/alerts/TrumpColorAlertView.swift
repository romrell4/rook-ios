//
//  TrumpColorAlertView.swift
//  Rook
//
//  Created by Eric Romrell on 5/12/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

class TrumpColorAlertView: GameAlertView {
	
	//MARK: Overriden properties
	override var shouldBeShowing: Bool { return game.state == .declareTrump && game.highBidder == Player.current }
	
	//MARK: Listeners
	
	@IBAction func redTapped(_ sender: UIButton) {
		suitTapped(RookCard.Suit.red)
	}
	@IBAction func greenTapped(_ sender: UIButton) {
		suitTapped(RookCard.Suit.green)
	}
	@IBAction func yellowTapped(_ sender: UIButton) {
		suitTapped(RookCard.Suit.yellow)
	}
	@IBAction func blueTapped(_ sender: UIButton) {
		suitTapped(RookCard.Suit.black)
	}
	
	//MARK: Custom functions
	
	private func suitTapped(_ suit: RookCard.Suit) {
		game.trumpSuit = suit
		game.state = .started
		DB.updateGame(game)
	}
}
