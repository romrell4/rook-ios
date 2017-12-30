//
//  Extensions.swift
//  Rook
//
//  Created by Eric Romrell on 12/29/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

extension UIColor {
	convenience init(r: Int, g: Int, b: Int, alpha: CGFloat = 1) {
		self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
	}
	
	static var rookRed: UIColor {
		return UIColor(r: 237, g:  37, b:  50)
	}
	
	static var rookGreen: UIColor {
		return UIColor(r:  36, g: 193, b:  80)
	}
	
	static var rookYellow: UIColor {
		return UIColor(r: 242, g: 199, b:  58)
	}
}

extension UIImage {
	convenience init?(named name: String, inView vc: UIView) {
		self.init(named: name, in: Bundle(for: type(of: vc)), compatibleWith: vc.traitCollection)
	}
}
