//
//  RookCardView.swift
//  Rook
//
//  Created by Eric Romrell on 12/29/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

let cardAspectRatio: CGFloat = 0.7

protocol RookCardViewDelegate {
	func cardSelected(_ cardView: RookCardView)
}

@IBDesignable
class RookCardView: UIView {
	
	private struct UI {
		static let backText = "ROOK"
		static let rookImageName = "RookSquare"
		static let backImageName = "RookBack"
		static let fontName = "Palatino-Bold"
		static let underlinedRanks = [6, 9]
	}
	
	//Public properties
	private (set) var card = RookCard()
	
	//Private properties
	private var delegate: RookCardViewDelegate?
	
	//Inspectable properties
	@IBInspectable private var isFaceUp: Bool {
		get { return card.isFaceUp }
		set { card.isFaceUp = newValue }
	}
	@IBInspectable private var rank: Int {
		get { return card.rank }
		set { card.rank = newValue }
	}
	@IBInspectable private var suit: String {
		get { return card.suit.text }
		set { card.suit = RookCard.Suit.fromText(text: newValue) }
	}
	@IBInspectable var selected: Bool = false {
		didSet {
			self.setNeedsDisplay()
		}
	}
	
	//Computed properties
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
	private var backFontSize		 : CGFloat { return bounds.width * 0.25 }
	private var backMargin	 		 : CGFloat { return bounds.width * 0.04 }
	private var backImageMargin		 : CGFloat { return bounds.width * 0.2 }
	
	//MARK: Initializers
	
	init(card: RookCard, delegate: RookCardViewDelegate? = nil, height: CGFloat? = nil) {
		self.init()
		self.card = card
		self.delegate = delegate
		
		translatesAutoresizingMaskIntoConstraints = false
		var constraints = [widthAnchor.constraint(equalTo: heightAnchor, multiplier: cardAspectRatio)]
		if let height = height {
			constraints.append(heightAnchor.constraint(equalToConstant: height))
		}
		NSLayoutConstraint.activate(constraints)
		setup()
	}
	
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
		backgroundColor = .clear
		isOpaque = false
	}
	
	//MARK: Listeners
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		delegate?.cardSelected(self)
	}
	
	//MARK: Drawing
	
	override func draw(_ rect: CGRect) {
		drawBaseCard()
		
		if card.isFaceUp {
			drawFront()
		} else {
			drawBack()
		}
	}
	
	private func drawBaseCard() {
		let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
		roundedRect.addClip()
		
		pushContext()
		
		selected ? UIColor.lighterGray.setFill() : UIColor.white.setFill()
		UIRectFill(bounds)
		roundedRect.lineWidth = 0.5
		roundedRect.stroke()
		popContext()
	}
	
	private func drawFront() {
		if card.suit == .rook {
			drawRook()
		} else {
			drawCenter()
		}
		
		drawCorners()
	}
	
	private func drawRook() {
		guard let rookImage = UIImage(named: UI.rookImageName, inView: self) else { return }
		
		let width = bounds.width - (2 * centerImageMargin)
		let imageRect = CGRect(x: centerImageMargin, y: (bounds.height - width) / 2, width: width, height: width)
		rookImage.draw(in: imageRect)
	}
	
	private func drawCenter() {
		//Draw rank
		let font = rookCardFont(ofSize: centerFontSize)
		let rankText = NSAttributedString(string: "\(card.rank)", attributes: [
			.font: font,
			.foregroundColor: card.suit.color
		])
		var textRect = CGRect.zero
		textRect.size = rankText.size()
		textRect.origin = CGPoint(x: (bounds.width - textRect.width) / 2, y: (bounds.height - textRect.height) / 2)
		rankText.draw(in: textRect)
		
		if UI.underlinedRanks.contains(rank) {
			let underline = UIBezierPath()
			let yOffset = textRect.origin.y + textRect.height + font.descender + underlineOffset
			
			pushContext()
			card.suit.color.setStroke()
			underline.move(to: CGPoint(x: textRect.origin.x + underlineInset, y: yOffset))
			underline.addLine(to: CGPoint(x: textRect.origin.x + textRect.width - underlineOffset, y: yOffset))
			underline.lineWidth = underlineStrokeWidth
			underline.stroke()
			popContext()
		}
		
		//Draw square
		let square = UIBezierPath()
		let width = bounds.width - (2 * squareMargin)
		let yOffset = (bounds.height - width) / 2
		
		pushContext()
		card.suit.color.setStroke()
		square.lineWidth = squareStrokeWidth
		square.move(to: CGPoint(x: squareMargin, y: yOffset))
		square.addLine(to: CGPoint(x: squareMargin + width, y: yOffset))
		square.addLine(to: CGPoint(x: squareMargin + width, y: yOffset + width))
		square.addLine(to: CGPoint(x: squareMargin, y: yOffset + width))
		square.close()
		square.stroke()
		popContext()
	}
	
	private func drawCorners() {
		//Setup the suit (it will be used
		let suitFont = rookCardFont(ofSize: cornerSuitFontSize)
		let suitText = NSAttributedString(string: "\(card.suit.text)", attributes: [
			.font: suitFont,
			.foregroundColor: card.suit.color
		])
		var suitRect = CGRect.zero
		suitRect.size = suitText.size()
		
		if card.suit == .rook {
			//Setup the rook image
			guard let rookImage = UIImage(named: UI.rookImageName, inView: self) else {
				return
			}
			
			let rookRect = CGRect(x: cornerXOffset, y: cornerYOffset, width: cornerImageWidth, height: cornerImageWidth)
			
			//Make the suitRect fit to the side of the rank
			suitRect.origin = CGPoint(x: cornerXOffset + cornerImageWidth + cornerSuitOffset, y: cornerYOffset)
			
			//Draw the rank and the suit name
			rookImage.draw(in: rookRect)
			suitText.draw(in: suitRect)
			
			//Do it again upside down
			pushContextAndFlipUpsideDown()
			rookImage.draw(in: rookRect)
			suitText.draw(in: suitRect)
			popContext()
		} else {
			//Setup the rank
			let rankFont = rookCardFont(ofSize: cornerRankFontSize)
			let rankText = NSAttributedString(string: "\(card.rank)", attributes: [
				.font: rankFont,
				.foregroundColor: card.suit.color
			])
			var rankRect = CGRect.zero
			rankRect.size = rankText.size()
			rankRect.origin = CGPoint(x: cornerXOffset, y: cornerYOffset - rankFont.lineHeight + rankFont.capHeight - rankFont.descender)
			
			//Make the suitRect fit to the side of the rank
			suitRect.origin = CGPoint(x: cornerXOffset + rankText.size().width + cornerSuitOffset, y: cornerYOffset)
			
			//Draw the rank and the suit name
			rankText.draw(in: rankRect)
			suitText.draw(in: suitRect)
			
			//Do it again upside down
			pushContextAndFlipUpsideDown()
			rankText.draw(in: rankRect)
			suitText.draw(in: suitRect)
			popContext()
		}
	}
	
	private func drawBack() {
		//Draw the background
		if let image = UIImage(named: UI.backImageName, inView: self) {
			let imageRect = CGRect(x: backMargin, y: backMargin, width: bounds.width - (2 * backMargin), height: bounds.height - (2 * backMargin))
			image.draw(in: imageRect)
		}
		
		//Draw the image/text
		guard let image = UIImage(named: UI.rookImageName, inView: self) else { return }
		let text = NSAttributedString(string: UI.backText, attributes: [
			.font: rookCardFont(ofSize: backFontSize),
			.strokeColor: UIColor.black,
			.strokeWidth: -3.0,
			.foregroundColor: UIColor.cardYellow
		])
		
		var textRect = CGRect.zero
		textRect.size = text.size()
		
		let width = bounds.width - (2 * backImageMargin)
		let totalHeight = width + textRect.height
		let imageRect = CGRect(x: backImageMargin, y: (bounds.height - totalHeight) / 2, width: width, height: width)
		textRect.origin = CGPoint(x: (bounds.width - textRect.width) / 2, y: (bounds.height - totalHeight) / 2 + width)

		image.draw(in: imageRect)
		text.draw(in: textRect)
	}
	
	//MARK: Helpers
	
	private func rookCardFont(ofSize fontSize: CGFloat) -> UIFont {
		guard let font = UIFont(name: UI.fontName, size: fontSize) else { return UIFont.preferredFont(forTextStyle: .body) }
		return font
	}
	
	private func pushContext() {
		UIGraphicsGetCurrentContext()?.saveGState()
	}
	
	private func pushContextAndFlipUpsideDown() {
		let context = UIGraphicsGetCurrentContext()
		context?.saveGState()
		context?.translateBy(x: bounds.width, y: bounds.height)
		context?.rotate(by: CGFloat(Double.pi))
	}
	
	private func popContext() {
		UIGraphicsGetCurrentContext()?.restoreGState()
	}
}
