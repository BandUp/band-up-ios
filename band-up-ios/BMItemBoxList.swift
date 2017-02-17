//
//  BMItemBoxList.swift
//  band-up-ios
//
//  Created by Bergþór on 5.2.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//


import UIKit
import UICollectionViewLeftAlignedLayout

@IBDesignable
class BMItemBoxList: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	// MARK: - Variables
	// MARK: Constants
	let CELL_VIEW_TAG = "cellTag"
	
	// MARK: IBInspectables
	@IBInspectable open var boxColor: UIColor?
	@IBInspectable open var borderColor: UIColor?
	@IBInspectable open var textColor: UIColor?
	
	@IBInspectable open var fontSize: CGFloat = 14.0
	@IBInspectable open var fontType = "System"
	
	@IBInspectable open var horizontalMargin: CGFloat = 0.0
	@IBInspectable open var verticalMargin: CGFloat = 0.0
	@IBInspectable open var horizontalPadding: CGFloat = 0.0
	@IBInspectable open var verticalPadding: CGFloat = 0.0
	
	@IBInspectable open var cornerRadius: CGFloat = 0.0
	@IBInspectable open var borderWidth: CGFloat = 0.0
	
	// MARK: Variables
	var strings: [String] = []
	var collectionView: UICollectionView?
	var layout: UICollectionViewLayout = UICollectionViewLeftAlignedLayout()

	override init(frame: CGRect) {
		super.init(frame: frame)
		initialize()
	}

	// MARK: - Initializers
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialize()
	}

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		strings = ["Item", "Text", "Box", "List"]
		initialize()
	}
	
	func update(strings newStrings: [String]) {
		for item in strings {
			if (!newStrings.contains(item)) {
				let myIndex: Int = strings.index(of: item)!
				strings.remove(at: myIndex)
				collectionView?.deleteItems(at: [IndexPath(row: myIndex, section: 0)])
			}
		}
		
		for (index, item) in newStrings.enumerated() {
			if (!strings.contains(item)) {
				strings.insert(item, at: index)
				layoutSubviews()
				collectionView?.insertItems(at: [IndexPath(row: index, section: 0)])
			}
		}
	}
	
	// MARK: - Overridden Functions
	override func layoutSubviews() {
		super.layoutSubviews()
		let size = CGSize(width: bounds.width, height: self.estimateHeight())
		collectionView?.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
		collectionView?.layoutSubviews()
		invalidateIntrinsicContentSize()
	}
	
	override var intrinsicContentSize : CGSize {
		return CGSize(width: self.frame.width, height: self.estimateHeight())
	}

	// MARK: - Collection View: Data Source and Delegates
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return strings.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let currCell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_VIEW_TAG, for: indexPath) as! BMItemBoxListCell
		
		// Font Style
		currCell.fontType = self.fontType
		currCell.fontSize = self.fontSize
		currCell.textColor =  self.textColor
		
		// Box style
		currCell.layer.borderWidth = borderWidth
		currCell.layer.borderColor = self.borderColor?.cgColor
		currCell.layer.cornerRadius = self.cornerRadius
		currCell.cornerRadius = self.cornerRadius
		currCell.layer.backgroundColor = self.boxColor?.cgColor
		
		// Content
		currCell.title = self.strings[indexPath.row]
		
		return currCell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let measuringLabel = UILabel()
		measuringLabel.text = self.strings[indexPath.row]
		measuringLabel.font = UIFont(name: fontType, size: fontSize)
		measuringLabel.font = measuringLabel.font.withSize(fontSize)

		var size = measuringLabel.intrinsicContentSize
		size.height += 2 * verticalPadding
		size.width += 2 * horizontalPadding

		return size
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return CGFloat(horizontalMargin)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return CGFloat(verticalMargin)
	}
	
	// MARK: - Helper Functions
	func initialize() {
		collectionView = UICollectionView(frame: self.frame, collectionViewLayout: layout)
		collectionView?.delegate = self
		collectionView?.dataSource = self
		collectionView?.backgroundColor = UIColor.clear
		collectionView?.register(BMItemBoxListCell.self, forCellWithReuseIdentifier: CELL_VIEW_TAG)
		if let collectionView = collectionView {
			self.addSubview(collectionView)
		}
	}
	
	func estimateHeight() -> CGFloat {
		let collectionWidth = self.bounds.width
		var currentWidthOfLine: CGFloat = 0.0
		var lines: CGFloat = 1
		let itemPadding : CGFloat = CGFloat(horizontalPadding * 2.0)
		let itemMargin: CGFloat = CGFloat(horizontalMargin)
		var labelHeight : CGFloat = 0.0

		for item in self.strings {
			
			let tmpLabel = UILabel()
			tmpLabel.text = item
			tmpLabel.font = UIFont(name: fontType, size: fontSize)
			tmpLabel.font = tmpLabel.font.withSize(fontSize)
			tmpLabel.sizeToFit()
			labelHeight = tmpLabel.frame.height
			let labelWidth = tmpLabel.intrinsicContentSize.width + itemPadding
			
			if collectionWidth >= (currentWidthOfLine + labelWidth) {
				currentWidthOfLine += labelWidth + itemMargin
			} else {
				currentWidthOfLine = labelWidth + itemMargin
				lines += 1
			}
		}
		
		let estimatedHeight = lines * (2 * verticalPadding + labelHeight) + (verticalMargin * (lines - 1))
		return estimatedHeight
	}
}
