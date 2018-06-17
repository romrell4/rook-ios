//
//  ViewController.swift
//  Rook
//
//  Created by Eric Romrell on 12/29/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit
import FirebaseDatabase

private let KITTY_SIZE = 5

class GameViewController: UIViewController, RookCardViewDelegate, AlertViewDelegate {
	//MARK: Outlets
	@IBOutlet private weak var myPlayedCardView: RookCardContainerView!
	@IBOutlet private weak var leftPlayedCardView: RookCardContainerView!
	@IBOutlet private weak var middlePlayedCardView: RookCardContainerView!
	@IBOutlet private weak var rightPlayedCardView: RookCardContainerView!
	
	@IBOutlet private var swipeViews: [UIStackView]!
	
	@IBOutlet private weak var alertParentView: UIView!
	@IBOutlet private weak var handStackView: UIStackView!
	@IBOutlet private weak var handStackViewHeightConstraint: NSLayoutConstraint!
	
	//MARK: Public properties
	var game: Game! {
		didSet {
			//If the game just changed to the started state, announce trump
			if oldValue?.currentHand?.trumpSuit == nil, let hand = game.currentHand, let trump = hand.trumpSuit, let winner = game.players.first(where: { $0.id == hand.bidWinner })?.name {
				//TODO: Brand this a little better...
				let alert = UIAlertController(title: "\(winner) has declared trump as \(trump)", message: nil, preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "OK", style: .default))
				present(alert, animated: true)
			}
		}
	}
	
	//Computed
	private var me: Player {
		return game.me!
	}
	private var playedCardViews: [RookCardContainerView] { return [myPlayedCardView, leftPlayedCardView, middlePlayedCardView, rightPlayedCardView] }
	private var handCardViews: [RookCardView] { return handStackView.subviews as? [RookCardView] ?? [] }
	
	private var cardHeight: CGFloat { return min(view.frame.height * 0.3, 200) }
	private var cardWidth: CGFloat { return cardHeight * cardAspectRatio }
	private var cardSpacing: CGFloat {
		if me.cards.count < 2 { return 0 } //Avoid divide by zero errors
		
		//For spacing, we get 80% of the width, minus one card's width (which will display completely)
		let availSpaceWidth = view.frame.width * 0.8 - cardWidth
		let spacePerCard = availSpaceWidth / CGFloat(me.cards.count - 1)
		return spacePerCard - cardWidth
	}
	
	//MARK: Private properties
	private var relayout = false
	private var currentAlert: GameAlertView?

	override func viewDidLoad() {
		super.viewDidLoad()
		
		game.join()
		
		title = me.name
		
		DB.gameRef(id: game.id).observe(.value) { (snapshot) in
			guard snapshot.exists() else { self.leaveTapped(); return }
			
			self.game = Game(snapshot: snapshot)
			self.handleStateAlerts()
			self.handleDrawingCards()
			self.handleShowDoneButton()
			self.handleWinningTrick()
			self.handleMyTurn()
		}
	}
	
	//These functions will take care of orientation change on the iPad
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) { relayout = true }
	override func viewDidLayoutSubviews() { if relayout { relayout = false; drawCards() } }
	
	//MARK: RookCardViewDelegate
	
	func cardSelected(_ cardView: RookCardView) {
		//TODO: Make a "cardMoved" and "cardDropped" to animate the motion
		
		if game.state == .discardAndDeclareTrump, game.highBidder == me {
			guard canSelectCardToDiscard(cardView: cardView) else { return }
			
			cardView.selected = !cardView.selected
			
			//If we have followed all the rules, allow the user to tap "Done"
			navigationItem.rightBarButtonItem?.isEnabled = handCardViews.filter { $0.selected }.count == KITTY_SIZE && game.currentHand?.trumpSuit != nil
		} else if game.state == .started && canPlay(card: cardView.card) {
			//Remove from stack view and add to played container view
			cardView.removeFromSuperview()
			myPlayedCardView.cardView = RookCardView(card: cardView.card) //Use constructor to reinitialize constraints
			
			me.cards.remove { $0 == cardView.card }
			me.playedCard = cardView.card
			
			if let player = whoseTurnIsNext() {
				game.turn = player.id
			} else {
				//Determine who won
				let winner = getTrickWinner()
				print("\(winner?.name ?? "") won this trick")
				
				game.turn = winner?.id
			}
			DB.updateGame(game)
		}
	}
	
	//MARK: TrumpAlertViewDelegate
	
	func trumpSelected(_ trumpSuit: RookCard.Suit) {
		game.currentHand?.trumpSuit = trumpSuit
		
		//Deselect all previously selected trump cards
		handCardViews.filter { $0.selected && $0.card.suit == trumpSuit }.forEach { $0.selected = false }
		
		navigationItem.rightBarButtonItem?.isEnabled = handCardViews.filter { $0.selected }.count == KITTY_SIZE && game.currentHand?.trumpSuit != nil
	}
	
	//MARK: Listeners
	
	@IBAction func leaveTapped(_ sender: Any? = nil) {
		DB.gameRef(id: game.id).removeAllObservers()
		dismiss(animated: true)
	}
	
	@IBAction func swipedToCollect() {
		if iWon() {
			swipeViews.forEach {
				$0.layer.removeAllAnimations()
				$0.alpha = 0
			}
			game.players.forEach {
				game.currentHand?.points[$0.teamNumber] += $0.playedCard?.points ?? 0
				$0.playedCard = nil
			}
			
			//If you have no cards, deal the next hand
			if me.cards.isEmpty {
				game.endHand()
				game.state = .bidding
			}
			
			DB.updateGame(game)
		}
	}
	
	@objc func doneTapped() {
		handCardViews.filter { $0.selected }.forEach { selectedCardView in
			selectedCardView.removeFromSuperview()
			me.cards.remove { $0 == selectedCardView.card }
		}
		
		drawCards()
		
		game.turn = game.me?.id
		game.state = .started
		DB.updateGame(game)
		
		//TODO: Announce trump color
	}
	
	//MARK: Private functions
	
	private func drawCards() {
		//Remove current cards and add new cards
		handStackView.subviews.forEach { $0.removeFromSuperview() }
		me.cards.forEach { handStackView.addArrangedSubview(RookCardView(card: $0, delegate: self, height: cardHeight)) }
		handStackViewHeightConstraint.constant = cardHeight
		handStackView.spacing = cardSpacing
	}
	
	private func canSelectCardToDiscard(cardView: RookCardView) -> Bool {
		//TODO: Implement the toasts below
		if cardView.selected {
			if !cardView.card.isPoint && handCardViews.filter({ $0.selected && $0.card.isPoint }).count > 0 {
				//showToast("Please deselect all point cards first")
				return false
			}
		} else {
			if cardView.card.suit == game.currentHand?.trumpSuit || cardView.card.suit == .rook {
				//showToast("You cannot discard trump")
				return false
			} else if cardView.card.isPoint && handCardViews.filter({ !($0.selected || $0.card.isPoint || $0.card.suit == game.currentHand?.trumpSuit) }).count != 0 {
				//showToast("You cannot discard points until all non-point values are selected")
				return false
			}
		}
		return true
	}
	
	private func canPlay(card: RookCard) -> Bool {
		//It's not your turn? Or it is your turn, but you've already played? No go.
		guard game.turn == game.me?.id && myPlayedCardView.cardView?.card == nil else { return false }
		
		//A card has been led? Maybe...
		if let ledCard = playedCardViews.first(where: { $0.cardView != nil })?.cardView?.card {
			//You can follow suit, but are trying not to? No go
			//TODO: Can we use nil as the rook suit? Then we could just default to trump...
			let cardsFollowingSuit = game.me?.cards.filter { $0.suit == ledCard.suit || $0.suit == .rook && ledCard.suit == game.currentHand?.trumpSuit || $0.suit == game.currentHand?.trumpSuit && ledCard.suit == .rook } ?? []
			if cardsFollowingSuit.count > 0 && !cardsFollowingSuit.contains(card) {
				return false
			}
		}
		
		return true
	}
	
	private func whoseTurnIsNext() -> Player? {
		//Find where I am in the list of players
		if let me = game.me, let myIndex = game.players.index(of: me) {
			//Get the next player
			let nextPlayer = game.players[myIndex + 1 % MAX_PLAYERS]
			
			//If they haven't played yet, it's their turn next
			if nextPlayer.playedCard == nil {
				return nextPlayer
			}
		}
		//Otherwise, the trick is over
		return nil
	}
	
	private func getTrickWinner() -> Player? {
		//You will only ever class this if you were the one to end the playing
		var cards = playedCardViews.compactMap { $0.cardView?.card }
		
		//Rotate the cards so that the leader is first
		cards.append(cards.removeFirst())
		
		var bestSoFar = cards.removeFirst()
		for nextCard in cards {
			if bestSoFar.suit == game.currentHand?.trumpSuit || bestSoFar.suit == .rook {
				//If best is trump, we have to be trump AND higher than them (no need to include rook, it will never beat a trump)
				if nextCard.suit == game.currentHand?.trumpSuit && nextCard.value > bestSoFar.value {
					bestSoFar = nextCard
				}
			} else {
				//If best is not trump, we can beat it with trump OR by following suit with a higher rank
				if nextCard.suit == game.currentHand?.trumpSuit || nextCard.suit == .rook || (nextCard.suit == bestSoFar.suit && nextCard.value > bestSoFar.value) {
					bestSoFar = nextCard
				}
			}
		}
		print("\(bestSoFar) wins")
		
		return game.players.first { $0.playedCard == bestSoFar }
	}
	
	private func iWon() -> Bool {
		return game.turn == me.id && me.playedCard != nil
	}
}

extension GameViewController {
	
	private func handleStateAlerts() {
		//Define closure to setup the pop-ups
		func setupPopup(withClass klass: GameAlertView.Type) -> GameAlertView? {
			let alert = Bundle.main.loadNibNamed(String(describing: klass), owner: nil)?.first as? GameAlertView
			alert?.setup(withDelegate: self, inView: alertParentView, withGame: game)
			alert?.updateGame(game)
			return alert
		}
		
		if let alertClass = game.state.getAlertClass(inGame: game) {
			//There is an alert associated with this state
			if let currentAlert = currentAlert {
				//We are showing an alert already
				if type(of: currentAlert) != alertClass {
					//We are showing a different alert. Dismiss it, then display ours
					currentAlert.dismiss {
						self.currentAlert = setupPopup(withClass: alertClass)
					}
				} else {
					//We are already showing this alert. Update it
					currentAlert.updateGame(game)
				}
			} else {
				//No alert showing. Just create the new one
				self.currentAlert = setupPopup(withClass: alertClass)
			}
		} else {
			//No alert should be showing. Dismiss it if there is
			currentAlert?.dismiss()
		}
	}
	
	private func handleDrawingCards() {
		//If I have cards, but they don't match my hand's stack view, redraw them
		if !me.cards.isEmpty, handStackView.subviews.count != me.cards.count {
			drawCards()
		}
		
		//Update the played cards
		game.players.forEach {
			var cardView: RookCardView?
			if let card = $0.playedCard {
				cardView = RookCardView(card: card)
			}
			
			//Find the position that this player is in, and update their card
			let position = (($0.sortNum ?? 0) - (me.sortNum ?? 0) + MAX_PLAYERS) % MAX_PLAYERS
			playedCardViews[position].cardView = cardView
		}
	}
	
	private func handleShowDoneButton() {
		//If we are in the kitty state, create a "Done" button so that the user can finish the kitty state
		if game.state == .discardAndDeclareTrump && game.highBidder == Player.current {
			navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(doneTapped))
			navigationItem.rightBarButtonItem?.isEnabled = false
		} else {
			navigationItem.rightBarButtonItem = nil
		}
	}
	
	private func handleWinningTrick() {
		//If you won, make the swipe view visible/pulsing
		if iWon() {
			//TODO: Fix error that happened in this sitation:
			//Player2: Red 1, Player1: Rook, Player3: Red 2, Player4: Red 5
			//Both Player2 and Player1 go the swipeViews animating
			swipeViews.forEach { swipeView in
				UIView.animate(withDuration: 1, delay: 0, animations: { swipeView.alpha = 1 }, completion: { (_) in
					UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse], animations: { swipeView.alpha = 0.5 }, completion: nil)
				})
			}
		}
	}
	
	private func handleMyTurn() {
		//If it's my turn, make my played card view pulse lightly
		if game.turn == game.me?.id {
			UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse], animations: {
				self.myPlayedCardView.backgroundColor = .cardContainerBright
			}, completion: nil)
		} else {
			myPlayedCardView.layer.removeAllAnimations()
			myPlayedCardView.backgroundColor = .cardContainer
		}
	}
}
