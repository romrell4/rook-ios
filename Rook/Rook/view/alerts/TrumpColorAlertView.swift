//
//  TrumpColorAlertView.swift
//  Rook
//
//  Created by Eric Romrell on 5/12/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

class TrumpColorAlertView: GameAlertView {
	
	//MARK: Listeners
	
	@IBAction func buttonTapped(_ sender: UIButton) {
		UIView.animate(withDuration: 0.5) {
			sender.superview?.subviews.forEach {
				$0.alpha = 0.5
				$0.layer.borderWidth = 0
			}
			sender.alpha = 1
			sender.layer.borderWidth = 1
		}
		delegate.trumpSelected(RookCard.Suit.fromText(text: sender.titleLabel?.text ?? ""))
	}
}
