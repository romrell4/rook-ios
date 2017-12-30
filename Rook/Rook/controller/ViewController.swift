//
//  ViewController.swift
//  Rook
//
//  Created by Eric Romrell on 12/29/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	//MARK: Outlets
	@IBOutlet private weak var handStackView: UIStackView!
	
	//MARK: Private properties
	private var game = Game.instance
	
	//Computed
	private var cardWidth: CGFloat { return view.frame.height * 0.25 }

	override func viewDidLoad() {
		super.viewDidLoad()
		
		game.deal()
		drawCards()
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
		me.cards.forEach { handStackView.addArrangedSubview(RookCardView(card: $0, width: cardWidth)) }
	}
}

