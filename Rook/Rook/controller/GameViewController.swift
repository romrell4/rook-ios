//
//  ViewController.swift
//  Rook
//
//  Created by Eric Romrell on 12/29/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit
import FirebaseDatabase

//TODO: Figure out a way to compute (rather than hard code) 5
private let KITTY_SIZE = 5

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
	private var handCardViews: [RookCardView] { return handStackView.subviews as? [RookCardView] ?? [] }
	
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
			"BiddingAlertView",
			"KittyAlertView",
			"TrumpColorAlertView"
		].map { Bundle.main.loadNibNamed($0, owner: nil)?.first as? GameAlertView }
		
		alerts.forEach { $0?.setup(superview: view, game: game) }
		
		DB.gameRef(id: game.id).observe(.value) { (snapshot) in
			self.game = Game(snapshot: snapshot)
			
			alerts.forEach { $0?.updateGame(self.game) }
			
			if !self.game.state.isPreGame {
				//If I have cards, but they don't match my hand's stack view, draw them
				if !self.me.cards.isEmpty, self.handStackView.subviews.count != self.me.cards.count {
					self.drawCards()
				}
				
				self.drawPlayedCards()
				
				//If we are in the kitty state, create a "Done" button so that the user can finish the kitty state
				if self.game.state == .kitty {
					self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneTapped))
					self.navigationItem.rightBarButtonItem?.isEnabled = false
				} else {
					self.navigationItem.rightBarButtonItem = nil
				}
			}
		}
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		//TODO: Redraw cards view, etc
		print("Redraw")
	}
	
	//MARK: RookCardViewDelegate
	
	func cardSelected(_ cardView: RookCardView) {
		//TODO: Make a "cardMoved" and "cardDropped" to animate the motion
		
		if game.state == .kitty, game.highBidder == me {
			//If the card is a point, and they still have other non-points to give, don't let them select it
			//TODO: Add some sort of toast to let them know that they can't select that one
			guard cardView.card.isKittyable || handCardViews.filter({ !$0.selected && $0.card.isKittyable}).count == 0 else { return }
			
			cardView.selected = !cardView.selected
			
			//If we have selected the right number of cards, allow the user to tap "Done"
			navigationItem.rightBarButtonItem?.isEnabled = handCardViews.filter { $0.selected }.count == KITTY_SIZE
		} else if game.state == .started {
			//Remove from stack view and add to played container view
			cardView.removeFromSuperview()
			myPlayedCardView.cardView = RookCardView(card: cardView.card) //Use constructor to reinitialize constraints
			
			me.cards.remove { $0 == cardView.card }
			me.playedCard = cardView.card

			DB.updateGame(game)
		}
	}
	
	//MARK: Listeners
	
	@IBAction func leaveTapped(_ sender: Any) {
		DB.gameRef(id: game.id).removeAllObservers()
		game.leave()
		dismiss(animated: true)
	}
	
	@objc func doneTapped() {
		let selectedCardViews = handCardViews.filter { $0.selected }
		guard selectedCardViews.count == KITTY_SIZE else { return }
		
		selectedCardViews.forEach { selectedCardView in
			selectedCardView.removeFromSuperview()
			me.cards.remove { $0 == selectedCardView.card }
		}
		
		drawCards()
		
		game.state = .declareTrump
		DB.updateGame(game)
	}
	
	//MARK: Private functions
	
	private func drawCards() {
		//TODO: Redraw when orientation switches on iPad
		
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
