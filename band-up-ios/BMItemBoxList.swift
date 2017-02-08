//
//  BMItemBoxList.swift
//  band-up-ios
//
//  Created by Bergþór on 5.2.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//


import UIKit
import UICollectionViewLeftAlignedLayout

class BMItemBoxList: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	// MARK: - Variables
	// MARK: Constants
	let CELL_VIEW_TAG = "cellTag"
	
	// MARK: IBInspectables
	@IBInspectable open var backColor: UIColor?
	@IBInspectable open var borderColor: UIColor?
	@IBInspectable open var textColor: UIColor?
	
	@IBInspectable open var fontSize: CGFloat = 17.0
	@IBInspectable open var fontType = "System"
	
	@IBInspectable open var horizontalMargin: CGFloat = 10
	@IBInspectable open var verticalMargin: CGFloat = 10
	@IBInspectable open var horizontalPadding: CGFloat = 6
	@IBInspectable open var verticalPadding: CGFloat = 3
	
	@IBInspectable open var cornerRadius: CGFloat = 3
	
	// MARK: Variables
	var strings: [String] = []
	var collectionView: UICollectionView?
	var layout: UICollectionViewLayout = UICollectionViewLeftAlignedLayout()
	

	// MARK: - Initializers
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialize()
	}
	
	// MARK: - Overridden Functions
	override func layoutSubviews() {
		super.layoutSubviews()
		let size = CGSize(width: bounds.width, height: self.estimateHeight())
		collectionView?.frame = CGRect(origin: CGPoint(x: 0,y: 0), size: size)
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
		currCell.layer.borderWidth = 0.5
		currCell.layer.borderColor = self.borderColor?.cgColor
		currCell.layer.cornerRadius = self.cornerRadius
		currCell.cornerRadius = self.cornerRadius
		currCell.contentView.backgroundColor = self.backColor
		
		// Content
		currCell.title = self.strings[indexPath.row]
		
		return currCell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let measuringLabel = UILabel()
		measuringLabel.text = self.strings[indexPath.row]
		
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
		let itemPadding : CGFloat = CGFloat(horizontalPadding * 2)
		let itemMargin: CGFloat = CGFloat(horizontalMargin)
		let itemHeight = fontSize + (verticalPadding * 2)
		let vertSpace = verticalMargin
		
		for item in self.strings {
			
			let tmpLabel = UILabel()
			tmpLabel.text = item
			tmpLabel.font = UIFont(name: fontType, size: fontSize)
			
			let labelWidth = tmpLabel.intrinsicContentSize.width + itemPadding
			
			if collectionWidth >= (currentWidthOfLine + labelWidth) {
				currentWidthOfLine += labelWidth + itemMargin
			} else {
				currentWidthOfLine = labelWidth + itemMargin
				lines += 1
			}
		}
		let estimatedHeight = (lines * 3.5) + CGFloat((itemHeight * lines)+((lines-1) * vertSpace))
		return estimatedHeight
	}
}
