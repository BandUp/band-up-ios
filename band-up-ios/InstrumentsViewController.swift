//
//  InstrumentsViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 15.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit

class InstrumentsViewController: UIViewController {
	
	@IBOutlet weak var collectionView: UICollectionView!
	
	var ITEM_NAME_TAG = 1;
	
	var setupItemArray = [String]()
	
	let itemsPerRow: CGFloat = 2
	let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		collectionView.delegate = self
		collectionView.dataSource = self
		setupItemArray = ["Vocals", "Guitar", "Percussion", "Bass", "Saxophone", "Strings", "Trumpet", "Electronics", "Keyboard", "Other"]

	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

extension InstrumentsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return setupItemArray.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
		let itemName = cell.viewWithTag(ITEM_NAME_TAG) as! UILabel;
		itemName.text = setupItemArray[indexPath.row]
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView,
	                    layout collectionViewLayout: UICollectionViewLayout,
	                    sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
		let availableWidth = view.frame.width - paddingSpace
		let itemHeight = (availableWidth/2-1) * 0.5
		
		return CGSize(width: availableWidth/2-1, height: itemHeight)
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		// TODO: Select the item with animation
		let itemName = collectionView.cellForItem(at: indexPath)?.viewWithTag(ITEM_NAME_TAG) as! UILabel;
		//itemName.text = "HELLO"

	}
}
