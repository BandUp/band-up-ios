//
//  BMChatLabel.swift
//  band-up-ios
//
//  Created by Bergþór on 19.2.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit

class BMChatLabel: UILabel {

	let inset = UIEdgeInsets(top: 5,left: 10,bottom: 5,right: 10)

	override var intrinsicContentSize: CGSize {
		let superSize = super.intrinsicContentSize
		let width = superSize.width + inset.left + inset.right
		let height = superSize.height + inset.top + inset.bottom
		return CGSize(width: width, height: height)
	}

	override func sizeThatFits(_ size: CGSize) -> CGSize {
		let superSize = super.sizeThatFits(size)
		let width = superSize.width + inset.left + inset.right
		let height = superSize.height + inset.top + inset.bottom
		return CGSize(width: width, height: height)
	}

	override func drawText(in rect: CGRect) {
		let insets = UIEdgeInsets(top: inset.top, left: inset.left, bottom: inset.bottom, right: inset.right)
		super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
	}

}
