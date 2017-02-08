//
//  BMItemBoxListCell.swift
//  band-up-ios
//
//  Created by Bergþór on 7.2.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit

class BMItemBoxListCell: UICollectionViewCell {
	
	var fontSize: CGFloat = 17.0
	var textColor: UIColor?
	var fontType = "System"
	var cornerRadius: CGFloat = 3.0
	
	var title = "" {
		didSet {
			update(label: boxText!, with: title)
		}
	}
	
	weak var boxText: UILabel?
	
	override func prepareForReuse() {
		super.prepareForReuse()
		title = ""
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	func setup() {
		let titleLabel = UILabel(frame: bounds)
		boxText = titleLabel
		update(label: boxText!, with: "")
		contentView.addSubview(titleLabel)
	}
	
	func update(label: UILabel, with text: String) {
		boxText?.text = text
		boxText?.font = UIFont(name: fontType, size: fontSize)
		boxText?.textColor = textColor
		boxText?.textAlignment = .center
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		boxText?.frame = bounds
		contentView.layer.cornerRadius = cornerRadius
	}
}
