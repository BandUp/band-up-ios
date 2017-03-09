//
//  BMItemBoxListCell.swift
//  band-up-ios
//
//  Created by Bergþór on 7.2.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit

class BMItemBoxListCell: UICollectionViewCell {

	// MARK: - Variables
	var fontSize: CGFloat = 11.0
	var textColor: UIColor?
	var fontType = "System"
	var cornerRadius: CGFloat = 3.0

	var title = "" {
		didSet {
			update(label: boxText!, with: title)
		}
	}

	weak var boxText: UILabel?

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}

	// MARK: - UICollectionViewCell Overrides
	override func prepareForReuse() {
		super.prepareForReuse()
		title = ""
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		boxText?.frame = bounds
		contentView.layer.cornerRadius = cornerRadius
	}

	// MARK: - Helper Functions
	func setup() {
		let titleLabel = UILabel(frame: bounds)
		boxText = titleLabel
		update(label: titleLabel, with: "")
		contentView.addSubview(titleLabel)
	}

	func update(label: UILabel, with text: String) {
		label.text = text
		label.font = UIFont(name: fontType, size: fontSize)
		label.font = label.font.withSize(fontSize)
		label.textColor = textColor

		label.textAlignment = .center
	}

}
