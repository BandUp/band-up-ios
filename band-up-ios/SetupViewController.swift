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
	
	// MARK: - Interface Builder Outlets
	@IBOutlet weak var lblTitleUpperLeft: UILabel!
	@IBOutlet weak var lblErrorLabel: UILabel!
	@IBOutlet weak var lblTitleUpperRight: UILabel!
	@IBOutlet weak var lblTitleHint: UILabel!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var btnNext: UIButton!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	// MARK: - Objects and Constants
	var ITEM_NAME_TAG = 1;
	var setupViewObject: [SetupViewObject]? = nil
	var stringArray = [String]()
	var setupItemArray = [SetupItem]()
	
	// MARK: - Overridden Functions
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(true, animated: false)
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		
		self.setupViewObject?.first?.apiResource.load().onSuccess({ (response) in
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			self.activityIndicator.stopAnimating()
			// Go through all of the setup items in the response
			for item in response.jsonArray {
				let itemDict = item as? NSDictionary
				
				// If it isn't a dictionary, then skip it.
				// Something is broken.
				if (itemDict == nil) {
					continue
				}
				
				// Now we are sure we have a dictionary
				// Unwrap it and get the strings.
				let _id   = itemDict!["_id"] as? String
				let _name = itemDict!["name"] as? String
				
				// If we don't find data, don't add it.
				if (_id == nil || _name == nil) {
					continue
				}
				// All is well.
				// Create a new object and unwrap the data into it.
				let setupItem = SetupItem(id: _id!, name: _name!)
				
				if (self.setupViewObject?.first?.selected.contains(_name!))! {
					setupItem.isSelected = true
				}
				
				self.setupItemArray.append(setupItem)
			}
			// And finally display the data
			// in the collection view
			self.collectionView.reloadData()
			if (self.setupItemArray.count == 0) {
				self.displayErrorMessage(message: "Could not fetch information")
			}
		}).onFailure({ (error) in
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			self.activityIndicator.stopAnimating()
			self.displayErrorMessage(message: "Could not fetch information")
			print(error)
		})
		
		super.viewWillAppear(animated)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		collectionView.delegate = self
		collectionView.dataSource = self
		// Set the text of the labels and buttons
		lblTitleUpperLeft.text = setupViewObject?.first?.titleUpperLeft
		
		let index = setupViewObject?.first?.setupViewIndex
		let count = setupViewObject?.first?.setupViewCount
		
		if index != 0 && count != 0 {
			lblTitleUpperRight.text = "\(index!)/\(count!)"
		} else {
			lblTitleUpperRight.text = ""
		}
		
		lblTitleHint.text = setupViewObject?.first?.titleHint
		btnNext.setTitle(setupViewObject?.first?.doneButtonText, for: .normal)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Interface Builder Actions
	@IBAction func onClickDone(_ sender: Any) {
		var idArr = [String]()
		for item in setupItemArray {
			if (item.isSelected) {
				idArr.append(item.id)
			}
		}
		
		if (idArr.count == 0) {
			NSLog("You need to select at least one!")
		} else {
			
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
			self.setupViewObject?.first?.apiResource.request(.post, json: idArr).onSuccess({ (response) in
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
			}).onFailure({ (error) in
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
			})
			
			
			if (setupViewObject?.first?.setupViewCount != setupViewObject?.first?.setupViewIndex) {
				// Setup has not been finished. Continue

				let myVC = storyboard?.instantiateViewController(withIdentifier: "SetupViewController") as! SetupViewController
				
				myVC.setupViewObject = Array((setupViewObject?.dropFirst())!)
				
				navigationController?.pushViewController(myVC, animated: true)
			} else {
				if (self.setupViewObject?.first?.shouldDismiss)! {
					dismiss(animated: true, completion: nil)
				} else {
					let storyboard = UIStoryboard(name: "DrawerView", bundle: Bundle.main)
					let vc = storyboard.instantiateViewController(withIdentifier: "DrawerController") as! KYDrawerController
					present(vc, animated: true, completion: nil)
					if (self.setupViewObject?.first?.shouldFinishSetup)! {
						UserDefaults.standard.set(true, forKey: DefaultsKeys.finishedSetup)
					}
				}
			}
		}
	}
	
	// MARK: - Helper Functions
	func displayErrorMessage(message : String) {
		self.lblErrorLabel.text = message
		self.lblErrorLabel.isHidden = false
	}
}

// MARK: - Extensions
extension SetupViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return setupItemArray.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let setupItem = setupItemArray[indexPath.row]
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
		
		let lblItemName = cell.viewWithTag(ITEM_NAME_TAG) as! UILabel;
		
		lblItemName.text = setupItem.name
		
		cell.layer.borderColor = UIColor.bandUpYellow.cgColor
		
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
		
		collectionView.cellForItem(at: indexPath)?.layer.borderColor = UIColor.bandUpYellow.cgColor
		
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

// MARK: - Helper Classes
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
	var shouldDismiss  : Bool = false
	var shouldFinishSetup: Bool = false
	var apiResource    : Resource
	var titleUpperLeft : String = ""
	var titleHint      : String = ""
	var doneButtonText : String = ""
	var setupViewIndex : Int = 0
	var setupViewCount : Int = 0
	var selected       : [String] = []
}
