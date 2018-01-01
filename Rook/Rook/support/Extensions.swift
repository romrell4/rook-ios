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

extension Array {
	mutating func shuffle() {
		let c = count
		guard c > 1 else { return }
		
		for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
			let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
			let i = index(firstUnshuffled, offsetBy: d)
			swapAt(firstUnshuffled, i)
		}
	}
	
	mutating func remove(where predicate: (Element) throws -> Bool) rethrows {
		if let tmp = try? self.index(where: predicate), let index = tmp {
			remove(at: index)
		}
	}
}
