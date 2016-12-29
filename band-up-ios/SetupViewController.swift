//
//  InstrumentsViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 15.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit
import KYDrawerController
import Siesta

class SetupViewController: UIViewController {
	
	var ITEM_NAME_TAG = 1;

	@IBOutlet weak var lblTitleUpperLeft: UILabel!
	@IBOutlet weak var lblTitleUpperRight: UILabel!
	@IBOutlet weak var lblTitleHint: UILabel!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var btnNext: UIButton!
	
	var setupViewObject: SetupViewObject? = nil
	
	
	var stringArray = [String]()
	var setupItemArray = [SetupItem]()
	
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(true, animated: false)
		
		self.setupViewObject?.apiResource.loadIfNeeded()?.onSuccess({ (success) in
			print(success)
		}).onFailure({ (error) in
			print(error)
		})
		
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
		if (idArr.count == 0) {
			NSLog("You need to select atleast one!")
		} else {
			if (setupViewObject?.setupViewCount != setupViewObject?.setupViewIndex) {
				// Setup has not been finished. Continue
				let setupObject = SetupViewObject(setupResource: bandUpAPI.genres)

				let myVC = storyboard?.instantiateViewController(withIdentifier: "SetupViewController") as! SetupViewController
				setupObject.doneButtonText = "Finish"
				setupObject.titleUpperLeft = "Let's get started"
				setupObject.setupViewIndex = 2
				setupObject.setupViewCount = 2
				setupObject.titleHint = "What is your taste in music?"
				myVC.setupViewObject = setupObject
				
				navigationController?.pushViewController(myVC, animated: true)
			} else {
				let storyboard = UIStoryboard(name: "MainScreen", bundle: nil)
				let vc = storyboard.instantiateViewController(withIdentifier: "DrawerController") as! KYDrawerController
				present(vc, animated: true, completion: nil)
			}
		}
		
		
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		collectionView.delegate = self
		collectionView.dataSource = self
		// Set the text of the labels and buttons
		lblTitleUpperLeft.text = setupViewObject?.titleUpperLeft
		
		let index = setupViewObject?.setupViewIndex
		let count = setupViewObject?.setupViewCount
		
		lblTitleUpperRight.text = "\(index!)/\(count!)"
		lblTitleHint.text = setupViewObject?.titleHint
		btnNext.setTitle(setupViewObject?.doneButtonText, for: .normal)
		
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
			anim.duration = 0.1
			anim.repeatCount = 0
			collectionView.cellForItem(at: indexPath)?.layer.borderWidth = 0
			collectionView.cellForItem(at: indexPath)?.layer.add(anim, forKey: "borderWidth")
			setupItemArray[indexPath.row].isSelected = false
		} else {
			let anim = CABasicAnimation(keyPath: "borderWidth")
			anim.fromValue = 0
			anim.toValue = 5
			anim.duration = 0.1
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

class SetupViewObject {
	init(setupResource: Resource) {
		apiResource = setupResource
	}
	
	var apiResource    : Resource
	var titleUpperLeft : String = ""
	var titleHint      : String = ""
	var doneButtonText : String = ""
	var setupViewIndex : Int = 0
	var setupViewCount : Int = 0
}
