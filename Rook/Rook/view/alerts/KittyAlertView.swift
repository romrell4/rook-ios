//
//  KittyAlertView.swift
//  Rook
//
//  Created by Eric Romrell on 1/29/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

class KittyAlertView: GameAlertView {
	
	//MARK: Overriden properties
	override var shouldBeShowing: Bool { return game.state == .kitty && game.highBidder == Player.current }
	
	//MARK: Overriden functions
	
	override func updateGame(_ game: Game) {
		super.updateGame(game)
		
		if shouldBeShowing {
			print("I'm here!")
		}
	}
}
