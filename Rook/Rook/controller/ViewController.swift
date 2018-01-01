//
//  ViewController.swift
//  Rook
//
//  Created by Eric Romrell on 12/29/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI

class ViewController: UIViewController, RookCardViewDelegate {
	//MARK: Outlets
	@IBOutlet private weak var myPlayedCardView: RookCardContainerView!
	@IBOutlet private weak var leftPlayedCardView: RookCardContainerView!
	@IBOutlet private weak var middlePlayedCardView: RookCardContainerView!
	@IBOutlet private weak var rightPlayedCardView: RookCardContainerView!
	@IBOutlet private weak var handStackView: UIStackView!
	
	//MARK: Private properties
	private var game = Game.instance
	
	//Computed
	private var playedCardViews: [RookCardContainerView] { return [myPlayedCardView, leftPlayedCardView, middlePlayedCardView, rightPlayedCardView] }
	private var me: Player { return game.players.first! }
	
	private var cardHeight: CGFloat { return min(view.frame.height * 0.3, 300) }
	private var cardWidth: CGFloat { return cardHeight * cardAspectRatio }
	private var cardSpacing: CGFloat {
		if me.cards.count > 1 { return 0 } //Avoid divide by zero errors
		
		//For spacing, we get 80% of the width, minus one card's width (which will display completely)
		let availSpaceWidth = view.frame.width * 0.8 - cardWidth
		let spacePerCard = availSpaceWidth / CGFloat(me.cards.count - 1)
		return spacePerCard - cardWidth
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		handleLogin {
			self.game.deal()
			self.drawCards()
		}
	}
	
	//MARK: RookCardViewDelegate
	
	func cardSelected(_ cardView: RookCardView) {
		//TODO: Make a "cardMoved" and "cardDropped" to animate the motion
		
		//Remove from stack view and add to played container view
		cardView.removeFromSuperview()
		myPlayedCardView.cardView = RookCardView(card: cardView.card)
		
		//Loop through all the OTHER player to play a card
		zip(game.players, playedCardViews)
			.filter { $0.0 != me }
			.forEach { $1.cardView = RookCardView(card: $0.cards.removeFirst()) }
	}
	
	//MARK: Listeners
	
	@IBAction func logoutTapped(_ sender: Any) {
		do {
			try Auth.auth().signOut()
		} catch {
			print("Error logging out")
		}
	}
	
	@IBAction func redealTapped(_ sender: Any) {
		playedCardViews.forEach({ $0.cardView = nil })
		game.deal()
		drawCards()
	}
	
	//MARK: Private functions
	
	private func handleLogin(callback: @escaping () -> Void) {
		if let authUI = FUIAuth.defaultAuthUI() {
			let auth = Auth.auth()
			authUI.providers = [FUIGoogleAuth()]
			auth.addStateDidChangeListener { (auth, user) in
				if user == nil {
					self.present(authUI.authViewController(), animated: true, completion: nil)
				} else {
					callback()
				}
			}
		}
	}
	
	private func drawCards() {
		//Remove current cards and add new cards
		handStackView.subviews.forEach({ $0.removeFromSuperview() })
		me.cards.forEach { handStackView.addArrangedSubview(RookCardView(card: $0, delegate: self, height: cardHeight)) }
		handStackView.heightAnchor.constraint(equalToConstant: cardHeight).isActive = true
		handStackView.spacing = cardSpacing
	}
}
