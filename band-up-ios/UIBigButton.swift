//
//  UIFullButton.swift
//  band-up-ios
//
//  Created by Bergþór on 30.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit

class UIBigButton: UIButton {
	override func layoutSubviews() {
		super.layoutSubviews()
		
		var frame = CGRect(x:0, y:0, width:(self.titleLabel?.frame.width)!, height:(self.titleLabel?.frame.height)!)
		frame.size.height = self.bounds.size.height
		frame.origin.y = self.titleEdgeInsets.top + 2
		frame.size.width = self.bounds.size.width
		self.titleLabel?.frame = frame
		self.titleLabel?.textAlignment = .center
		self.layer.cornerRadius = 15
	}
}
