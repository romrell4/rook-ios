//
//  GameAlertView.swift
//  Rook
//
//  Created by Eric Romrell on 1/23/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

class GameAlertView: UIView {
	
	//MARK: Public properties
	var game: Game!
	var shouldBeShowing: Bool {
		//NOTE: Override this
		return true
	}
	
	//MARK: Private properties
	private weak var centerYConstraint: NSLayoutConstraint!
	
	private struct UI {
		static let slideInterval: TimeInterval = 0.8
	}
	
	//Public functions
	
	func setup(superview: UIView, game: Game) {
		self.game = game
		
		frame = superview.frame
		superview.addSubview(self)
		
		centerYConstraint = superview.centerYAnchor.constraint(equalTo: self.centerYAnchor)
		NSLayoutConstraint.activate([
			centerYConstraint,
			superview.centerXAnchor.constraint(equalTo: self.centerXAnchor)
		])
		layoutIfNeeded()
		
		updateUI(showing: shouldBeShowing, animated: false)
	}
	
	func updateUI(showing: Bool, animated: Bool = true) {
		let currentlyShowing = centerYConstraint.constant == 0
		if currentlyShowing != showing {
			centerYConstraint.constant = showing ? 0 : UIScreen.main.bounds.height
			UIView.animate(withDuration: animated ? UI.slideInterval : 0) {
				self.layoutIfNeeded()
			}
		}
	}
}
