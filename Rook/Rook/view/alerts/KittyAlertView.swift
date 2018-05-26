//
//  KittyAlertView.swift
//  Rook
//
//  Created by Eric Romrell on 1/29/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

class KittyAlertView: GameAlertView {
	
	//MARK: Outlets
	@IBOutlet private weak var kittyStackView: UIStackView!
	
	//MARK: Private properties
	private var cardHeight: CGFloat = 75
	
	//MARK: Overriden functions
	
	override func updateGame(_ game: Game) {
		super.updateGame(game)
		
		//Remove current cards and add new cards
		kittyStackView.subviews.forEach { $0.removeFromSuperview() }
		game.kitty?.forEach { kittyStackView.addArrangedSubview(RookCardView(card: $0, delegate: nil, height: cardHeight)) }
		kittyStackView.heightAnchor.constraint(equalToConstant: cardHeight).isActive = true
	}
	
	//MARK: Listeners
	
	@IBAction func addKittyTapped(_ sender: UIButton) {
		if let kitty = game.kitty {
			game.me?.cards.append(contentsOf: kitty)
			game.me?.cards.sort()
			game.kitty = nil
			game.state = .discardAndDeclareTrump
			DB.updateGame(game)
		}
	}
}
