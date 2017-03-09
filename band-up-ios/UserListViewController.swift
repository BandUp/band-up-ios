//
//  UserListPageViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 29.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit
import CoreLocation
import Siesta

class UserListViewController: UIViewController {

	// MARK: - IBOutlets
	@IBOutlet weak var userCollectionView: UICollectionView!
	@IBOutlet weak var lblError: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	// MARK: - Variables
	let userCell = "user_item_cell"

	var userArray: [User] = [] {
		didSet {
			if userArray.count == 0 {
				self.userCollectionView.isHidden = true
				self.lblError.isHidden = false
				self.lblError.text = "user_list_no_users".localized
			} else {
				self.userCollectionView.isHidden = false
				self.lblError.isHidden = true
			}
		}
	}
	var currentIndex : CGFloat = 0

	// MARK: - Lazy Variables
	public lazy var userDetailsViewController: UserDetailsViewController = {
		let storyboard = UIStoryboard(name: Storyboard.userDetails, bundle: Bundle.main)

		if let viewController =  storyboard.instantiateViewController(withIdentifier: ControllerID.userDetails) as? UserDetailsViewController {
			return viewController
		}

		return UserDetailsViewController()
	}()

	// MARK: - UIViewController Overrides
	override func viewDidLoad() {
		super.viewDidLoad()
		registerForPreviewing(with: self, sourceView: userCollectionView)
		self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(someAction))

		loadUserList()

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(self.locationChanged(notification:)),
			name: NSNotification.Name(rawValue: "NewLocation"),
			object: nil)

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(self.unitsChanged(notification:)),
			name: NSNotification.Name(rawValue: "UnitsChanged"),
			object: nil)
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(someAction))

	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		reload(section: 0, animated: false)
	}

	// MARK: - Notification Handlers
	func locationChanged(notification: NSNotification) {
		print("Location Changed")
		BandUpAPI.sharedInstance.nearby.load().onSuccess { (response) in
			var tempUserArr = [User]()
			for user in response.jsonArray {
				if let jsonUser = user as? NSDictionary {
					let newUser = User(jsonUser)
					if self.shouldDisplay(user: newUser) {
						tempUserArr.append(newUser)
					}
				}
			}

			for item in self.userArray {
				if !tempUserArr.contains(item) {
					let myIndex: Int = self.userArray.index(of: item)!
					self.userArray.remove(at: myIndex)
					self.userCollectionView?.deleteItems(at: [IndexPath(row: myIndex, section: 0)])
				}
			}

			for (index, item) in tempUserArr.enumerated() {
				if !self.userArray.contains(item) {
					self.userArray.insert(item, at: index)
					self.userCollectionView?.insertItems(at: [IndexPath(row: index, section: 0)])
				}
			}
		}.onFailure { (error) in

		}
	}

	func unitsChanged(notification: NSNotification) {
		reload(section: 0, animated: false)
	}

	func reload(section: Int, animated: Bool) {
		if !animated {
			UIView.setAnimationsEnabled(false)
			userCollectionView.reloadSections(IndexSet(integer: section))

			UIView.setAnimationsEnabled(true)
		} else {
			userCollectionView.reloadSections(IndexSet(integer: section))
		}
	}
	// MARK: - Helper Functions
	func shouldDisplay(user: User) -> Bool {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
			return false
		}

		if user.location.valid {
			let radius = UserDefaults.standard.float(forKey: DefaultsKeys.Settings.radius)

			if let myLocation = appDelegate.lastKnownLocation {
				if user.getDistance(myLocation: myLocation) < Int(radius) {
					return true
				}
			} else {
				if user.distance < Double(radius) && user.distance != 0.0 {
					return true
				}
			}
		}

		return false
	}

	public func someAction() {
		let storyboard = UIStoryboard(name: Storyboard.search, bundle: Bundle.main)

		if let viewController = storyboard.instantiateInitialViewController() {
			self.present(viewController, animated: true, completion: nil)
		}
	}

	func loadUserList() {

		BandUpAPI.sharedInstance.nearby.load().onSuccess { (response) in
			self.activityIndicator.stopAnimating()

			self.userArray = []
			for user in response.jsonArray {
				if let jsonUser = user as? NSDictionary {
					let newUser = User(jsonUser)
					if self.shouldDisplay(user: newUser) {
						self.userArray.append(newUser)
					}
				}
			}

			self.userArray.shuffle()
			self.userCollectionView.reloadData()
			}.onFailure { (error) in
				self.activityIndicator.stopAnimating()
				self.lblError.isHidden = false
				self.lblError.text = "user_list_error_fetch_list".localized
				print(error.userMessage)
		}
	}

	// MARK: - IBActions
	@IBAction func didClickDetails(_ sender: UIButton) {
		userDetailsViewController.currentUser = userArray[Int(currentIndex)]
		self.navigationController?.pushViewController(userDetailsViewController, animated: true)
	}

	@IBAction func didClickLike(_ sender: UIButton) {
		let likedUser = userArray[Int(currentIndex)]

		BandUpAPI.sharedInstance.like.request(.post, json: ["userID": likedUser.id]).onSuccess { (response) in

			if let isMatch = response.jsonDict["isMatch"] as? Bool {
				likedUser.isLiked = true
				sender.setTitle("user_list_liked".localized, for: .normal)
				sender.isEnabled = false

				if isMatch {
					sender.setTitle("user_list_matched".localized, for: .normal)
					sender.isEnabled = false
				}
			}
			}.onFailure { (error) in
		}
	}

}
// MARK: - Extensions
// MARK: Collection View Implementation
extension UserListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return userArray.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userCell, for: indexPath) as? UserListItemViewCell else {
			return UICollectionViewCell()
		}
		cell.user = userArray[indexPath.row]
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView,
	                    layout collectionViewLayout: UICollectionViewLayout,
	                    sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		return CGSize(width: view.frame.width, height: view.frame.height)
	}
	
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
			return
		}

		guard let userCell = cell as? UserListItemViewCell else {
			return
		}

		if let lastLocation = appDelegate.lastKnownLocation {
			userCell.lblDistance.text = userCell.user?.getDistanceString(between: lastLocation)
		}
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		currentIndex = self.userCollectionView.contentOffset.x / self.userCollectionView.frame.size.width
	}

}

// MARK: 3D touch Implementation
extension UserListViewController: UIViewControllerPreviewingDelegate {
	
	// If you return nil, a preview presentation will not be performed
	public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		userDetailsViewController.currentUser = userArray[Int(currentIndex)]
		
		let indexPath: IndexPath = IndexPath(item: Int(currentIndex), section: 0)

		guard let itemCell = userCollectionView.cellForItem(at: indexPath) as? UserListItemViewCell else {
			return nil
		}

		let imageViewRect = itemCell.imgUserImage.frame
		let newX = location.x - itemCell.imgUserImage.frame.width * currentIndex

		let newLocation = CGPoint(x: newX, y: location.y)
		
		if !imageViewRect.contains(newLocation) {
			return nil
		}
		
		let sourceRect = previewingContext.sourceView.convert(imageViewRect, from: userCollectionView.superview)

		previewingContext.sourceRect = sourceRect
		userDetailsViewController.shouldDisplayLike = false
		return userDetailsViewController
		
	}
	
	public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
		userDetailsViewController.shouldDisplayLike = true
		show(userDetailsViewController, sender: self)
	}

}

// MARK: Shuffle Implementation
extension MutableCollection where Index == Int {

	// Shuffle the elements of `self` in-place.
	mutating func shuffle() {
		// empty and single-element collections don't shuffle
		if count < 2 {
			return
		}
		
		for i in startIndex ..< endIndex - 1 {
			let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
			if i != j {
				swap(&self[i], &self[j])
			}
		}
	}

}
