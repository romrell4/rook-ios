//
//  RookCardView.swift
//  Rook
//
//  Created by Eric Romrell on 12/29/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

@IBDesignable
class RookCardView: UIView {
	
	private struct UI {
		static let suitColors: [RookCard.Suit : UIColor] = [
			.rook   : UIColor(r:  34, g: 193, b: 196),
			.red    : UIColor(r: 237, g:  37, b:  50),
			.green  : UIColor(r:  36, g: 193, b:  80),
			.yellow : UIColor(r: 242, g: 199, b:  58),
			.black  : UIColor.black
		]
		static let underlinedRanks = [6, 9]
	}
	
	//MARK: Public properties
	var card = RookCard()
	
	//MARK: Inspectable properties
	@IBInspectable var isFaceUp: Bool {
		get { return card.isFaceUp }
		set { card.isFaceUp = newValue }
	}
	@IBInspectable var rank: Int {
		get { return card.rank }
		set { card.rank = newValue }
	}
	@IBInspectable var suit: String {
		get { return card.suit.description }
		set {
			if let suit = RookCard.Suit(rawValue: newValue) {
				card.suit = suit
			}
		}
	}
	
	//MARK: Computed properties
	
	private var centerFontSize       : CGFloat { return bounds.width * 0.55 }
	private var centerImageMargin    : CGFloat { return bounds.width * 0.15 }
	private var cornerImageWidth     : CGFloat { return bounds.width * 0.18 }
	private var cornerRadius         : CGFloat { return bounds.width * 0.05 }
	private var cornerRankFontSize   : CGFloat { return bounds.width * 0.2 }
	private var cornerSuitFontSize   : CGFloat { return bounds.width * 0.0666 }
	private var cornerSuitOffset     : CGFloat { return bounds.width * 0.01 }
	private var cornerXOffset        : CGFloat { return bounds.width * 0.0556 }
	private var cornerYOffset        : CGFloat { return bounds.width * 0.0667 }
	private var squareMargin         : CGFloat { return bounds.width * 0.189 }
	private var squareStrokeWidth    : CGFloat { return bounds.width * 0.005 }
	private var underlineOffset      : CGFloat { return bounds.width * 0.0333 }
	private var underlineInset       : CGFloat { return bounds.width * 0.0222 }
	private var underlineStrokeWidth : CGFloat { return bounds.width * 0.0111 }
	
	//MARK: Initializers
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		setup()
	}
	
	private func setup() {
		backgroundColor = UIColor.clear
		isOpaque = false
	}
	
	//MARK: Drawing
	
	override func draw(_ rect: CGRect) {
		drawBaseCard()
	}
	
	private func drawBaseCard() {
		let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
		roundedRect.addClip()
		
		_ = pushContext()
		UIColor.white.setFill()
		UIRectFill(bounds)
		popContext()
	}
	
	private func pushContext() -> CGContext? {
		let context = UIGraphicsGetCurrentContext()
		context?.saveGState()
		return context
	}
	
	private func popContext() {
		UIGraphicsGetCurrentContext()?.restoreGState()
	}
}
