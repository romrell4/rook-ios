//
//  ViewController.swift
//  Rook
//
//  Created by Eric Romrell on 12/29/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class ViewController: UIViewController, RookCardViewDelegate {
	
	//MARK: Outlets
	@IBOutlet weak var playedCardContainerView: RookCardContainerView!
	@IBOutlet private weak var handStackView: UIStackView!
	
	//MARK: Private properties
	private var game = Game.instance
	
	//Computed
	private var myCards: [RookCard] { return game.players.first?.cards ?? [] }
	
	private var cardHeight: CGFloat { return min(view.frame.height * 0.3, 300) }
	private var cardWidth: CGFloat { return cardHeight * cardAspectRatio }
	private var cardSpacing: CGFloat {
		guard myCards.count > 1 else { return 0 } //Avoid divide by zero errors
		
		//For spacing, we get 80% of the width, minus one card's width (which will display completely)
		let availSpaceWidth = view.frame.width * 0.8 - cardWidth
		let spacePerCard = availSpaceWidth / CGFloat(myCards.count - 1)
		return spacePerCard - cardWidth
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		game.deal()
		drawCards()
	}
	
	//MARK: RookCardViewDelegate
	
	func cardSelected(_ cardView: RookCardView) {
		//TODO: Make a "cardMoved" and "cardDropped" to animate the motion
		
		//Remove from stack view and add to played container view
		cardView.removeFromSuperview()
		playedCardContainerView.cardView = RookCardView(card: cardView.card, delegate: nil)
	}
	
	//MARK: Listeners
	
	@IBAction func redealTapped(_ sender: Any) {
		game.deal()
		drawCards()
	}
	
	//MARK: Private functions
	
	private func drawCards() {
		//TODO: Identify "me" better than using the first
		guard let me = game.players.first else { return }
		
		//Remove current cards and add new cards
		handStackView.subviews.forEach({ $0.removeFromSuperview() })
		me.cards.forEach { handStackView.addArrangedSubview(RookCardView(card: $0, delegate: self, height: cardHeight)) }
		handStackView.spacing = cardSpacing
	}
}

