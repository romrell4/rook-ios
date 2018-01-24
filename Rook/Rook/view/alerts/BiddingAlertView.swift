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
	@IBOutlet private weak var cancelButton: UIButton!
	
	//MARK: Computed properties
	override var shouldBeShowing: Bool {
		return super.game.state == .bidding
	}
	
	//MARK: Listeners
	
	@IBAction func stepperTapped(_ sender: UIStepper) {
		
	}
	
	@IBAction func submitTapped(_ sender: UIButton) {
		
	}
	
	@IBAction func cancelTapped(_ sender: UIButton) {
		
	}
}
