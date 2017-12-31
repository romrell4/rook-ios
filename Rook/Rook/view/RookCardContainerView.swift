//
//  RookCardContainerView.swift
//  Rook
//
//  Created by Eric Romrell on 12/30/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

class RookCardContainerView: UIView {
	var cardView: RookCardView? {
		didSet {
			//Remove the previous card
			oldValue?.removeFromSuperview()
			
			//Add the new card
			if let cardView = cardView {
				addSubview(cardView)
				NSLayoutConstraint.activate([
					heightAnchor.constraint(equalTo: cardView.heightAnchor),
					centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
					centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
				])
			}
		}
	}
}
