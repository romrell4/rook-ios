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
	@IBOutlet private weak var passButton: UIButton!
	
	//MARK: Overriden properties
	override var shouldBeShowing: Bool { return super.game.state == .bidding }
	override var centerYBuffer: CGFloat { return 50 }
	
	private struct UI {
		static let dimAlpha: CGFloat = 0.4
	}
	
	//MARK: Public functions
	
	override func updateGame(_ game: Game) {
		super.updateGame(game)
		
		if shouldBeShowing {
			let myBid = game.currentBidder == game.me?.id
			if let currentBid = game.currentBid {
				//Update the minimum stepper value (if it's your bid, set the stepper to 5 over the current bid)
				stepper.minimumValue = Double(currentBid) + (myBid ? stepper.stepValue : 0)
				updateBidLabel(stepper)
			} else if myBid {
				//If it's our bid, update it so that it shows "50" rather than "-"
				updateBidLabel(stepper)
			}
			let bidder = game.players.first(where: { $0.id == game.currentBidder })
			textLabel.text = getText(bidder: bidder)
			bidLabel.alpha = myBid ? 1 : UI.dimAlpha
			stepper.isEnabled = myBid
			stepper.tintColor = myBid ? .defaultTint : .lightGray
			submitButton.isEnabled = myBid
			passButton.isEnabled = myBid
		}
	}
	
	//MARK: Listeners
	
	@IBAction func updateBidLabel(_ sender: UIStepper) {
		bidLabel.text = "\(Int(sender.value))"
	}
	
	@IBAction func submitTapped(_ sender: UIButton) {
		updateBid(Int(stepper.value))
	}
	
	@IBAction func passTapped(_ sender: UIButton) {
		updateBid(nil)
	}
	
	//MARK: Private functions
	
	private func updateBid(_ bid: Int?) {
		//Only the current bidder can submit a bid
		guard let me = game.me,
			game.currentBidder == me.id,
			let mySortNum = me.sortNum,
			let nextPlayer = game.players.first(where: { $0.sortNum == ((mySortNum + 1) % MAX_PLAYERS) })
			else { return }
		
		if let bid = bid {
			game.currentBid = bid
			game.highBidder = game.currentBidder
		}
		game.currentBidder = nextPlayer.id
		DB.updateGame(game)
	}
	
	private func getText(bidder: Player?) -> String {
		var part1: String = ""
		if bidder == Player.currentPlayer {
			if let currentBid = game.currentBid {
				part1 = "The bid is at \(currentBid)."
			} else {
				part1 = "You start the bidding."
			}
		}
		let part2 = bidder == Player.currentPlayer ? "What would you like to bid?" : "Waiting for \(bidder?.name ?? "")"
		return "\(part1) \(part2)"
	}
}
