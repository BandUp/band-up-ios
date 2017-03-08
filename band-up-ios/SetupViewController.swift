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

protocol SetupViewControllerDelegate: class {
	func didSave(_ setup: Int, with data: [String])
}

class SetupViewController: UIViewController {
	
	weak var delegate: SetupViewControllerDelegate?
	
	// MARK: - Interface Builder Outlets
	@IBOutlet weak var lblTitleUpperLeft: UILabel!
	@IBOutlet weak var lblErrorLabel: UILabel!
	@IBOutlet weak var lblTitleUpperRight: UILabel!
	@IBOutlet weak var lblTitleHint: UILabel!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var btnNext: UIButton!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	// MARK: - Objects and Constants
	var itemNameTag = 1
	var setupViewObject: [SetupViewObject]?
	var stringArray = [String]()
	var setupItemArray = [SetupItem]()
	var selectedBorderWidth: CGFloat = 5
	
	// MARK: - Overridden Functions
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(true, animated: false)

		self.setupViewObject?.first?.apiResource.load().onSuccess { (response) in
			self.activityIndicator.stopAnimating()
			// Go through all of the setup items in the response
			for item in response.jsonArray {
				let itemDict = item as? NSDictionary
				
				// If it isn't a dictionary, then skip it.
				// Something is broken.
				if itemDict == nil {
					continue
				}
				
				// Now we are sure we have a dictionary
				// Unwrap it and get the strings.
				let id   = itemDict!["_id"] as? String
				let name = itemDict!["name"] as? String
				
				// If we don't find data, don't add it.
				if id == nil || name == nil {
					continue
				}
				// All is well.
				// Create a new object and unwrap the data into it.
				let setupItem = SetupItem(id: id!, name: name!)
				
				if (self.setupViewObject?.first?.selected.contains(name!))! {
					setupItem.isSelected = true
				}
				
				self.setupItemArray.append(setupItem)
			}
			// And finally display the data
			// in the collection view
			self.collectionView.reloadData()
			if self.setupItemArray.count == 0 {
				self.displayErrorMessage(message: "Could not fetch information")
			}
		}.onFailure { (error) in
			self.activityIndicator.stopAnimating()
			self.displayErrorMessage(message: "Could not fetch information")
			print(error)
		}
		
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
			if item.isSelected {
				idArr.append(item.id)
			}
		}
		
		if idArr.count == 0 {
			NSLog("You need to select at least one!")
		} else {
			
			let request = self.setupViewObject?.first?.apiResource.request(.post, json: idArr)

			request?.onSuccess { (response) in
				print(response)
			}.onFailure { (error) in
				print(error)
			}
			
			if setupViewObject?.first?.setupViewCount != setupViewObject?.first?.setupViewIndex {
				// Setup has not been finished. Continue

				guard let myVC = storyboard?.instantiateViewController(withIdentifier: ControllerID.setup) as? SetupViewController else { return }
				
				myVC.setupViewObject = Array((setupViewObject?.dropFirst())!)
				
				navigationController?.pushViewController(myVC, animated: true)
			} else {
				if (self.setupViewObject?.first?.shouldDismiss)! {
					dismiss(animated: true, completion: {
						if let del = self.delegate {
							var nameArr = [String]()
							for item in self.setupItemArray {
								if item.isSelected {
									nameArr.append(item.name)
								}
							}
							del.didSave((self.setupViewObject?.first?.id)!, with: nameArr)
						}
					})
				} else {
					guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
						print("Couldn't find AppDelegate")
						return
					}

					appDelegate.displayMainScreenView()

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
		
		if let lblItemName = cell.viewWithTag(itemNameTag) as? UILabel {
			lblItemName.text = setupItem.name
		} else {
			print("Could not find lblItemName")
		}

		cell.layer.borderColor = UIColor.bandUpYellow.cgColor
		
		if setupItem.isSelected {
			cell.layer.borderWidth = selectedBorderWidth
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
		
		if setupItemArray[indexPath.row].isSelected {
			let anim = CABasicAnimation(keyPath: "borderWidth")
			anim.fromValue = selectedBorderWidth
			anim.toValue = 0
			anim.duration = 0.1
			anim.repeatCount = 0
			collectionView.cellForItem(at: indexPath)?.layer.borderWidth = 0
			collectionView.cellForItem(at: indexPath)?.layer.add(anim, forKey: "borderWidth")
			setupItemArray[indexPath.row].isSelected = false
		} else {
			let anim = CABasicAnimation(keyPath: "borderWidth")
			anim.fromValue = 0
			anim.toValue = selectedBorderWidth
			anim.duration = 0.1
			anim.repeatCount = 0
			collectionView.cellForItem(at: indexPath)?.layer.borderWidth = selectedBorderWidth
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
	var id : Int?
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
