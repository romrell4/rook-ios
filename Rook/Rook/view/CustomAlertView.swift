//
//  CustomAlertView.swift
//  Rook
//
//  Created by Eric Romrell on 1/4/18.
//  Copyright © 2018 Eric Romrell. All rights reserved.
//

import UIKit

class CustomAlertView: UIView {
	
	//MARK: Outlets
	@IBOutlet private weak var centerYConstraint: NSLayoutConstraint!
	@IBOutlet weak var textLabel: UILabel!
	@IBOutlet weak var topImage: UIImageView!
	@IBOutlet weak var leftImage: UIImageView!
	@IBOutlet weak var rightImage: UIImageView!
	@IBOutlet weak var bottomImage: UIImageView!
	
	private struct UI {
		static let size: CGFloat = 300
		static let slideInterval: TimeInterval = 0.8
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	//Public functions
	
	func setup(superview: UIView) {
		frame = superview.frame
		superview.addSubview(self)
		
		//This will put the dialog into position
		layoutIfNeeded()
	}
	
	func show() {
		centerYConstraint.constant = 0
		UIView.animate(withDuration: UI.slideInterval) {
			self.layoutIfNeeded()
		}
	}
	
	func dismiss() {
		centerYConstraint.constant = frame.height
		UIView.animate(withDuration: UI.slideInterval) {
			self.layoutIfNeeded()
		}
	}
	
	
	//Private functions
	
	private func didTapOnBackgroundView() {
		dismiss()
	}
}
