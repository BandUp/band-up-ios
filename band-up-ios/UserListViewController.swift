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

	// MARK - Variables
	var userArray: [User] = []
	var currentIndex : CGFloat = 0

	public lazy var userDetailsViewController: UserDetailsViewController = {
		let storyboard = UIStoryboard(name: "UserDetailsView", bundle: Bundle.main)

		var viewController =  storyboard.instantiateViewController(withIdentifier: "UserDetailsViewController") as! UserDetailsViewController

		return viewController
	}()

	// MARK: - UIViewController Overrides
	override func viewDidLoad() {
		super.viewDidLoad()
		registerForPreviewing(with: self, sourceView: userCollectionView)
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		
		BandUpAPI.sharedInstance.nearby.load().onSuccess({ (response) in
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			self.activityIndicator.stopAnimating()
			
			for user in response.jsonArray {
				if let jsonUser = user as? NSDictionary {
					self.userArray.append(User(jsonUser))
				}
			}
			
			self.userArray.shuffle()
			self.userCollectionView.reloadData()
		}).onFailure({ (error) in
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			self.activityIndicator.stopAnimating()
			self.lblError.isHidden = false
			self.lblError.text = "user_list_error_fetch_list".localized
			print(error.userMessage)
		})
		
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
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		reload(section: 0, animated: false)
	}

	// MARK: - Notification Handlers
	func locationChanged(notification: NSNotification) {
		reload(section: 0, animated: false)
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

	// MARK: - IBActions
	@IBAction func didClickDetails(_ sender: UIButton) {
		userDetailsViewController.currentUser = userArray[Int(currentIndex)]
		self.navigationController?.pushViewController(userDetailsViewController, animated: true)
	}

	@IBAction func didClickLike(_ sender: UIButton) {
		let likedUser = userArray[Int(currentIndex)]
		UIApplication.shared.isNetworkActivityIndicatorVisible = true

		BandUpAPI.sharedInstance.like.request(.post, json: ["userID": likedUser.id]).onSuccess { (response) in
			UIApplication.shared.isNetworkActivityIndicatorVisible = false

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
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
		}
	}
}

// MARK: - Collection View Implementation
extension UserListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return userArray.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "user_item_cell", for: indexPath) as! UserListItemViewCell
		cell.user = userArray[indexPath.row]
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView,
	                    layout collectionViewLayout: UICollectionViewLayout,
	                    sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		return CGSize(width: view.frame.width, height: view.frame.height)
	}
	
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

		let userCell = cell as! UserListItemViewCell
		let appDelegate = UIApplication.shared.delegate as! AppDelegate

		if let lastLocation = appDelegate.lastKnownLocation {
			userCell.lblDistance.text = userCell.user.getDistanceString(between: lastLocation)
		}
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		currentIndex = self.userCollectionView.contentOffset.x / self.userCollectionView.frame.size.width
	}

}

// MARK: - 3D touch Implementation
extension UserListViewController: UIViewControllerPreviewingDelegate {
	
	// If you return nil, a preview presentation will not be performed
	public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		userDetailsViewController.currentUser = userArray[Int(currentIndex)]
		
		
		let indexPath: IndexPath = IndexPath(item: Int(currentIndex), section: 0)

		let itemCell = userCollectionView.cellForItem(at: indexPath) as! UserListItemViewCell
		
		let imageViewRect = itemCell.imgUserImage.frame
		let newX = location.x - itemCell.imgUserImage.frame.width * currentIndex

		let newLocation = CGPoint(x: newX, y: location.y)
		
		if (!imageViewRect.contains(newLocation)) {
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

// MARK: - Shuffle Implementation
extension MutableCollection where Index == Int {
	/// Shuffle the elements of `self` in-place.
	mutating func shuffle() {
		// empty and single-element collections don't shuffle
		if count < 2 { return }
		
		for i in startIndex ..< endIndex - 1 {
			let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
			if i != j {
				swap(&self[i], &self[j])
			}
		}
	}
}
