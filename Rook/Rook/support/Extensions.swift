//
//  Extensions.swift
//  Rook
//
//  Created by Eric Romrell on 12/29/17.
//  Copyright © 2017 Eric Romrell. All rights reserved.
//

import UIKit

extension Array {
	mutating func shuffle() {
		let c = count
		guard c > 1 else { return }
		
		for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
			let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
			let i = index(firstUnshuffled, offsetBy: d)
			swapAt(firstUnshuffled, i)
		}
	}
	
	mutating func remove(where predicate: (Element) throws -> Bool) rethrows {
		if let tmp = try? self.index(where: predicate), let index = tmp {
			remove(at: index)
		}
	}
	
	func associate<Key, Value>(_ keyAndTransform: (Element) -> (Key, Value)) -> [Key: Value] {
		return reduce(into: [:], { (dict, element) in
			let (key, value) = keyAndTransform(element)
			dict[key] = value
		})
	}
}

extension UIColor {
	convenience init(_ name: String) { self.init(named: name)! }
	
	static var cardContainerBright: UIColor { return UIColor("cardContainerBright") }
	static var cardContainer: UIColor { return UIColor("cardContainer") }
	static var cardGreen: UIColor {	return UIColor("cardGreen") }
	static var cardRed: UIColor { return UIColor("cardRed") }
	static var cardYellow: UIColor { return UIColor("cardYellow") }
	static var defaultTint: UIColor { return UIColor("defaultTint") }
	static var lighterGray: UIColor { return UIColor("lighterGray") }
}

extension UIImage {
	convenience init?(named name: String, inView vc: UIView) {
		self.init(named: name, in: Bundle(for: type(of: vc)), compatibleWith: vc.traitCollection)
	}
	
	convenience init?(fromUrl url: URL?) {
		if let url = url, let data = try? Data(contentsOf: url) {
			self.init(data: data)
		} else {
			return nil
		}
	}
}

extension UITableView {
	open override func awakeFromNib() {
		tableFooterView = UIView()
		super.awakeFromNib()
	}
}

extension URL {
	init?(string: String?) {
		if let string = string {
			self.init(string: string)
		} else {
			return nil
		}
	}
}
