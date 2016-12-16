//
//  InstrumentsViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 15.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController {
	
	var ITEM_NAME_TAG = 1;
	
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var btnNext: UIButton!
	
	var stringArray = [String]()
	var setupItemArray = [SetupItem]()
	
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(true, animated: animated)
		super.viewWillAppear(animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
	
	@IBAction func onClickDone(_ sender: Any) {
		var idArr = [String]()
		for item in setupItemArray {
			if (item.isSelected) {
				idArr.append(item.id)
			}
		}
		NSLog(idArr.description)
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		collectionView.delegate = self
		collectionView.dataSource = self
		
		
		stringArray = ["Vocals",      "Drums",
		               "Guitar",      "Percussion",
		               "Bass",        "Saxophone",
		               "Strings",     "Trumpet",
		               "Electronics", "Piano",
		               "Keyboard",    "Other"]
		
		for item in stringArray {
			let setupItem = SetupItem(id: item, name: item)
			setupItemArray.append(setupItem)
		}
		

	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

extension SetupViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return setupItemArray.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let setupItem = setupItemArray[indexPath.row]
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
		
		let lblItemName = cell.viewWithTag(ITEM_NAME_TAG) as! UILabel;
		
		lblItemName.text = setupItem.name
		
		cell.layer.borderColor = UIColor(red:255/255.0, green:211/255.0, blue:2/255.0, alpha: 1.0).cgColor
		
		if (setupItem.isSelected) {
			cell.layer.borderWidth = 5
		} else {
			cell.layer.borderWidth = 0
		}
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView,
	                    layout collectionViewLayout: UICollectionViewLayout,
	                    sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		let frameWidth = view.frame.width
		let itemWidth = (frameWidth / 2) - 1
		let itemHeight = itemWidth * 0.5
		
		return CGSize(width: itemWidth, height: itemHeight)
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		collectionView.cellForItem(at: indexPath)?.layer.borderColor = UIColor(red:255/255.0, green:211/255.0, blue:2/255.0, alpha: 1.0).cgColor

		
		if (setupItemArray[indexPath.row].isSelected) {
			let anim = CABasicAnimation(keyPath: "borderWidth")
			anim.fromValue = 5
			anim.toValue = 0
			anim.duration = 0.05
			anim.repeatCount = 0
			collectionView.cellForItem(at: indexPath)?.layer.borderWidth = 0
			collectionView.cellForItem(at: indexPath)?.layer.add(anim, forKey: "borderWidth")
			setupItemArray[indexPath.row].isSelected = false
		} else {
			let anim = CABasicAnimation(keyPath: "borderWidth")
			anim.fromValue = 0
			anim.toValue = 5
			anim.duration = 0.05
			anim.repeatCount = 0
			collectionView.cellForItem(at: indexPath)?.layer.borderWidth = 5
			collectionView.cellForItem(at: indexPath)?.layer.add(anim, forKey: "borderWidth")
			setupItemArray[indexPath.row].isSelected = true
		}
		
	}
}

class SetupItem {
	init(id: String, name: String) {
		self.id = id
		self.name = name
	}
	
	var id: String = ""
	var name: String = ""
	var isSelected: Bool = false
}
