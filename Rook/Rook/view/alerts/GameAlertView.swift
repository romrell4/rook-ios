//
//  GameAlertView.swift
//  Rook
//
//  Created by Eric Romrell on 1/23/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

protocol AlertViewDelegate {
	func trumpSelected(_ suit: RookCard.Suit)
}

class GameAlertView: UIView {
	
	//MARK: Public properties
	var delegate: AlertViewDelegate!
	var game: Game!
	
	//MARK: Private properties
	private weak var centerYConstraint: NSLayoutConstraint!
	
	private struct UI {
		static let slideInterval: TimeInterval = 0.8
	}
	
	//Public functions
	
	func setup(withDelegate delegate: AlertViewDelegate, inView parentView: UIView, withGame game: Game) {
		self.delegate = delegate
		self.game = game
		
		//Set up the border
		layer.cornerRadius = 10
		layer.borderColor = UIColor.black.cgColor
		layer.borderWidth = 1
		
		frame = parentView.frame
		parentView.addSubview(self)

		translatesAutoresizingMaskIntoConstraints = false
		
		centerYConstraint = parentView.centerYAnchor.constraint(equalTo: centerYAnchor)
		NSLayoutConstraint.activate([
			parentView.centerXAnchor.constraint(equalTo: centerXAnchor),
			centerYConstraint
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
