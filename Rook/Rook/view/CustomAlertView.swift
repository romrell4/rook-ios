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
	@IBOutlet weak var dialogView: UIStackView!
	@IBOutlet weak var centerYConstraint: NSLayoutConstraint!
	
	private struct UI {
		static let size: CGFloat = 300
		static let slideInterval: TimeInterval = 1
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
