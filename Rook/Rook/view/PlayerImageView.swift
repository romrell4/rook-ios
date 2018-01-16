//
//  PlayerImageView.swift
//  Rook
//
//  Created by Eric Romrell on 1/14/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

class PlayerImageView: UIImageView {
	var player: Player? {
		didSet {
			if let player = player {
				image = player.photo
			} else {
				image = UIImage(named: "user")
			}
		}
	}
}
