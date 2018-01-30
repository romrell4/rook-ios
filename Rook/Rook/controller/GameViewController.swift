//
//  ViewController.swift
//  Rook
//
//  Created by Eric Romrell on 12/29/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit
import FirebaseDatabase

class GameViewController: UIViewController, RookCardViewDelegate {
	//MARK: Outlets
	@IBOutlet private weak var myPlayedCardView: RookCardContainerView!
	@IBOutlet private weak var leftPlayedCardView: RookCardContainerView!
	@IBOutlet private weak var middlePlayedCardView: RookCardContainerView!
	@IBOutlet private weak var rightPlayedCardView: RookCardContainerView!
	@IBOutlet private weak var handStackView: UIStackView!
	
	//MARK: Public properties
	var game: Game!
	
	//Computed
	private var me: Player {
		return game.me!
	}
	private var playedCardViews: [RookCardContainerView] { return [myPlayedCardView, leftPlayedCardView, middlePlayedCardView, rightPlayedCardView] }
	
	private var cardHeight: CGFloat { return min(view.frame.height * 0.3, 200) }
	private var cardWidth: CGFloat { return cardHeight * cardAspectRatio }
	private var cardSpacing: CGFloat {
		if me.cards.count < 2 { return 0 } //Avoid divide by zero errors
		
		//For spacing, we get 80% of the width, minus one card's width (which will display completely)
		let availSpaceWidth = view.frame.width * 0.8 - cardWidth
		let spacePerCard = availSpaceWidth / CGFloat(me.cards.count - 1)
		return spacePerCard - cardWidth
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		game.join()
		
		title = me.name
		
		let alerts = [
			"PreGameAlertView",
			"BiddingAlertView"
		].map { Bundle.main.loadNibNamed($0, owner: nil)?.first as? GameAlertView }
		
		alerts.forEach { $0?.setup(superview: view, game: game) }
		
		DB.gameRef(id: game.id).observe(.value) { (snapshot) in
			self.game = Game(snapshot: snapshot)
			
			alerts.forEach { $0?.updateGame(self.game) }
			
			if !self.game.state.isPreGame {
				//If I have cards, but they aren't drawn yet, draw them
				if !self.me.cards.isEmpty, self.handStackView.subviews.isEmpty {
					self.drawCards()
				}
				
				self.drawPlayedCards()
			}
		}
	}
	
	//MARK: RookCardViewDelegate
	
	func cardSelected(_ cardView: RookCardView) {
		//TODO: Make a "cardMoved" and "cardDropped" to animate the motion
		
		//Remove from stack view and add to played container view
		cardView.removeFromSuperview()
		myPlayedCardView.cardView = RookCardView(card: cardView.card) //Use constructor to reinitialize constraints
		
		me.cards.remove { $0 == cardView.card }
		me.playedCard = cardView.card

		DB.updateGame(game)
	}
	
	//MARK: Listeners
	
	@IBAction func leaveTapped(_ sender: Any) {
		DB.gameRef(id: game.id).removeAllObservers()
		game.leave()
		dismiss(animated: true)
	}
	
	@IBAction func redealTapped(_ sender: Any) {
		game.players.forEach { $0.playedCard = nil }
		game.deal()
		DB.updateGame(game)
		drawCards()
	}
	
	//MARK: Private functions
	
	private func drawCards() {
		//Remove current cards and add new cards
		handStackView.subviews.forEach { $0.removeFromSuperview() }
		me.cards.forEach { handStackView.addArrangedSubview(RookCardView(card: $0, delegate: self, height: cardHeight)) }
		handStackView.heightAnchor.constraint(equalToConstant: cardHeight).isActive = true
		handStackView.spacing = cardSpacing
	}
	
	private func drawPlayedCards() {
		game.players.forEach {
			var cardView: RookCardView?
			if let card = $0.playedCard {
				cardView = RookCardView(card: card)
			}
			getPlayedCardView(forPlayer: $0).cardView = cardView
		}
	}
	
	private func getPlayedCardView(forPlayer player: Player) -> RookCardContainerView {
		let position = ((player.sortNum ?? 0) - (me.sortNum ?? 0) + MAX_PLAYERS) % MAX_PLAYERS
		return playedCardViews[position]
	}
}
