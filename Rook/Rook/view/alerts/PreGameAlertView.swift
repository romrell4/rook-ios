//
//  CustomAlertView.swift
//  Rook
//
//  Created by Eric Romrell on 1/4/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

class PreGameAlertView: GameAlertView {
	
	//MARK: Outlets
	@IBOutlet private weak var textLabel: UILabel!
	@IBOutlet private weak var topImage: PlayerImageView!
	@IBOutlet private weak var leftImage: PlayerImageView!
	@IBOutlet private weak var rightImage: PlayerImageView!
	@IBOutlet private weak var bottomImage: PlayerImageView!
	
	//MARK: Overriden properties
	override var shouldBeShowing: Bool {
		return super.game.state.isPreGame
	}
	private var imageViews: [PlayerImageView] { return [leftImage, topImage, rightImage] }
	
	//Public functions
	
	override func updateGame(_ game: Game) {
		super.updateGame(game)
		
		if shouldBeShowing {
			
			//TODO: Redraw images when someone leaves
			
			//Setup the images
			bottomImage.player = game.me
			zip(imageViews, game.players.filter { $0 != Player.current }) //Remove yourself from the list
				.forEach { $0.0.player = $0.1 } //Set the images for the others
			if game.state == .waitingForPlayers {
				let waitingAmount = MAX_PLAYERS - game.players.count
				if waitingAmount == 0 {
					game.state = .waitingForTeams
					DB.updateGame(game)
				} else {
					textLabel.text = "Waiting for \(waitingAmount) other player\(waitingAmount != 1 ? "s" : "")"
				}
			} else if game.state == .waitingForTeams {
				textLabel.text = game.owner == Player.current?.id ? "Please select your partner" : "Waiting for teams to be chosen by the game leader"
			}
		}
	}
	
	//MARK: Listeners
	
	@IBAction func photoTapped(_ sender: UITapGestureRecognizer) {
		//Only the owner should be able to select a partner, and only when the game is waiting for teams
		guard game.state == .waitingForTeams, game.me?.id == game.owner else { return }
		
		if let selectedPlayer = (sender.view as? PlayerImageView)?.player {
			//Set up the sort numbers for each player. After doing this, all new games will have the players sorted correctly
			game.me?.sortNum = 0
			game.players.first { $0 == selectedPlayer }?.sortNum = 2
			game.players.first { $0.sortNum == nil }?.sortNum = 1
			game.players.first { $0.sortNum == nil }?.sortNum = 3
			game.deal()
			
			DB.updateGame(game)
		}
	}
}
