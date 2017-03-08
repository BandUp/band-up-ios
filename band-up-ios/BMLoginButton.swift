//
//  BM.swift
//  band-up-ios
//
//  Created by Bergþór on 4.3.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit

@IBDesignable class BMLoginButton: UIButton {

	// MARK: - IBInspectables
	@IBInspectable open var cornerRadius: CGFloat = 0.0
	@IBInspectable open var imagePadding: CGFloat = 0.0
	@IBInspectable open var backColor: UIColor = UIColor.clear
	@IBInspectable open var highlightedColor: UIColor = UIColor.clear

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		initialize()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialize()
	}

	// MARK: - UIButton Overrides
	override var isHighlighted: Bool {
		didSet {
			if isHighlighted {
				self.backgroundColor = highlightedColor
			} else {
				self.backgroundColor = backColor
			}
		}
	}

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		initialize()
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		setColors()
	}

	// MARK: - Helper Functions
	func initialize() {
		setColors()
		setInsets()
	}

	func setInsets() {
		guard let imageView = imageView else {
			return
		}

		guard let image = imageView.image else {
			return
		}

		titleEdgeInsets = UIEdgeInsets(top: 0.0, left: bounds.height-image.size.width, bottom: 0.0, right: 0.0)
		backgroundColor = backColor

	}

	func setColors() {
		self.backgroundColor = backColor
		if highlightedColor != UIColor.clear {
			highlightedColor = backColor
		}

		backgroundColor = backColor
		clipsToBounds = true
		layer.cornerRadius = cornerRadius
		imageEdgeInsets = UIEdgeInsets(top: imagePadding, left: imagePadding, bottom: imagePadding, right: bounds.width-bounds.height+imagePadding)

		imageView?.contentMode = .scaleAspectFit

	}

}
