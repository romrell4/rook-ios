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
}
