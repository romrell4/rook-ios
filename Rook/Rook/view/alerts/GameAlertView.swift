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
	
	//MARK: Private properties
	private weak var centerYConstraint: NSLayoutConstraint!
	
	private struct UI {
		static let slideInterval: TimeInterval = 0.8
	}
	
	//Public functions
	
	func setup(superview: UIView, game: Game) {
		self.game = game
		
		//Set up the border
		layer.cornerRadius = 10
		layer.borderColor = UIColor.black.cgColor
		layer.borderWidth = 1
		
		frame = superview.frame
		superview.addSubview(self)
		
		translatesAutoresizingMaskIntoConstraints = false
		
		//Define the center y constraint so that we can set it's priority low. That way, the alert will cover the cards before it goes off screen
		let centerYConstraint = superview.centerYAnchor.constraint(equalTo: centerYAnchor)
		centerYConstraint.priority = UILayoutPriority.defaultLow
		
		NSLayoutConstraint.activate([
			superview.centerXAnchor.constraint(equalTo: centerXAnchor),
			centerYConstraint,
			superview.topAnchor.constraint(lessThanOrEqualTo: topAnchor)
		])
		layoutIfNeeded()
	}
	
	func updateGame(_ game: Game) {
		self.game = game
	}
	
	func dismiss(callback: (() -> Void)? = nil) {
		centerYConstraint.constant = UIScreen.main.bounds.height
		UIView.animate(withDuration: UI.slideInterval) {
			self.layoutIfNeeded()
		}
		UIView.animate(withDuration: UI.slideInterval, animations: {
			self.layoutIfNeeded()
		}) { _ in
			callback?()
		}
	}
}
