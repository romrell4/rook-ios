//
//  BiddingAlertView.swift
//  Rook
//
//  Created by Eric Romrell on 1/23/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

class BiddingAlertView: GameAlertView {
	//MARK: Outlets
	@IBOutlet private weak var textLabel: UILabel!
	@IBOutlet private weak var bidLabel: UILabel!
	@IBOutlet private weak var stepper: UIStepper!
	@IBOutlet private weak var submitButton: UIButton!
	
	//MARK: Overriden properties
	override var shouldBeShowing: Bool {
		return super.game.state == .bidding
	}
	override var centerYBuffer: CGFloat {
		return 50
	}
	
	//MARK: Public functions
	
	override func updateGame(_ game: Game) {
		super.updateGame(game)
		
		if shouldBeShowing {
			
			stepperTapped(stepper)
		}
	}
	
	//MARK: Listeners
	
	@IBAction func stepperTapped(_ sender: UIStepper) {
		bidLabel.text = "\(Int(sender.value))"
	}
	
	@IBAction func submitTapped(_ sender: UIButton) {
		
	}
}
