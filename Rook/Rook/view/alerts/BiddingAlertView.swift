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
	@IBOutlet var nameLabels: [UILabel]!
	@IBOutlet var bidLabels: [UILabel]!
	
	private struct UI {
		static let dimAlpha: CGFloat = 0.4
	}
	
	//MARK: Public functions
	
	override func updateGame(_ game: Game) {
		super.updateGame(game)
		
		//If I just took the bid (everyone else passed)
		if game.players.filter({ $0 != Player.current && $0.passed != true }).count == 0 {
			game.state = .viewKitty
			DB.updateGame(game)
			return
		}
		
		//Update the other people's bids
		for ((nameLabel, bidLabel), player) in zip(zip(nameLabels, bidLabels), game.players.filter { $0 != Player.current }) {
			nameLabel.text = "\(player.name ?? "Player"):"
			bidLabel.text = player.passed ?? false ? "Passed" : player.bid?.description ?? "-"
		}
		
		let myBid = game.currentBidder == game.me?.id
		if let currentBid = game.highBidder?.bid {
			//Update the minimum stepper value (if it's your bid, set the stepper to 5 over the current bid)
			stepper.minimumValue = Double(currentBid) + (myBid ? stepper.stepValue : 0)
			stepper.value = stepper.minimumValue
			updateBidLabel(stepper)
		} else {
			//If it's our bid, update it so that it shows "50" rather than "-"
			updateBidLabel(myBid ? stepper : nil)
		}
		let bidder = game.players.first(where: { $0.id == game.currentBidder })
		textLabel.text = getText(bidder: bidder)
		bidLabel.alpha = myBid ? 1 : UI.dimAlpha
		stepper.isEnabled = myBid
		stepper.tintColor = myBid ? .defaultTint : .lightGray
		submitButton.isEnabled = myBid
		passButton.isEnabled = myBid
	}
	
	//MARK: Listeners
	
	@IBAction func updateBidLabel(_ sender: UIStepper?) {
		if let sender = sender {
			bidLabel.text = "\(Int(sender.value))"
		} else {
			bidLabel.text = "-"
		}
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
		if game.me?.id != game.currentBidder { return }
		
		let nextPlayer = getNextBidder()
		
		if let bid = bid {
			game.me?.bid = bid
		} else {
			game.me?.passed = true
		}
		game.currentBidder = nextPlayer?.id
		DB.updateGame(game)
	}
	
	private func getNextBidder() -> Player? {
		if let me = Player.current, let myIndex = game.players.index(of: me) {
			for i in 1 ..< MAX_PLAYERS {
				let player = game.players[(myIndex + i) % MAX_PLAYERS]
				if !(player.passed ?? false) {
					return player
				}
			}
		}
		return nil
	}
	
	private func getText(bidder: Player?) -> String {
		var part1: String = ""
		var part2: String
		if bidder == Player.current {
			if let currentBid = game.highBidder?.bid {
				part1 = "The bid is at \(currentBid)."
			} else {
				part1 = "You start the bidding."
			}
			part2 = "What would you like to bid?"
		} else {
			part2 = "Waiting for \(bidder?.name ?? "")"
		}
		return "\(part1) \(part2)"
	}
}
