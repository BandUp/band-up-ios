//
//  UserDetailsViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 18.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit
import CoreLocation

class UserDetailsViewController: UIViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var lblAboutMe: UILabel!
	@IBOutlet weak var lblGenresList: UILabel!
	@IBOutlet weak var lblPercentage: UILabel!
	@IBOutlet weak var lblDistance: UILabel!
	@IBOutlet weak var lblInstrumentList: UILabel!
	@IBOutlet weak var lblFavInstrument: UILabel!
	@IBOutlet weak var lblAge: UILabel!
	@IBOutlet weak var lblUsername: UILabel!
	@IBOutlet weak var imgUserImage: RemoteImageView!
	@IBOutlet weak var actIndicator: UIActivityIndicatorView!
	@IBOutlet weak var btnLike: UIBigButton!
	@IBOutlet weak var likeButtonHeight: NSLayoutConstraint!
	
	// MARK: - Variables
	var currentUser = User()
	var shouldDisplayLike = true
	
	// MARK: - UIViewController Overrides
	override func viewDidLoad() {
		super.viewDidLoad()
		populateUser()

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(self.locationChanged),
			name: NSNotification.Name(rawValue: "NewLocation"),
			object: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		shouldDisplayLike = true

	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.title = "main_title_user_details".localized
		populateUser()
		if shouldDisplayLike {
			likeButtonHeight.constant = 85
			btnLike.isHidden = false
		} else {
			likeButtonHeight.constant = 0
			btnLike.isHidden = true
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - Notification Handlers
	func locationChanged(notification: NSNotification) {
		guard let locations = notification.userInfo?["locations"] else { return }
		lblDistance.text = currentUser.getDistanceString(between: (locations as! [CLLocation])[0])
	}
	
	// MARK: - IBActions
	@IBAction func didClickLike(_ sender: UIBigButton) {
		
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		
		BandUpAPI.sharedInstance.like.request(.post, json: ["userID": self.currentUser.id]).onSuccess { (response) in
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			
			if let isMatch = response.jsonDict["isMatch"] as? Bool {
				self.currentUser.isLiked = true
				sender.setTitle("user_list_liked".localized, for: .normal)
				sender.isEnabled = false
				
				if isMatch {
					sender.setTitle("user_list_matched".localized, for: .normal)
				}
			}
			}.onFailure { (error) in
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
		}
	}
	
	// MARK: - Helper Functions
	func populateUser() {
		imgUserImage.image = nil
		
		self.imgUserImage.delegate = self
		self.imgUserImage.placeholderImage = #imageLiteral(resourceName: "ProfilePlaceholder")
		self.imgUserImage.imageURL = URL(string: currentUser.image.url)

		if (currentUser.isLiked) {
			btnLike.setTitle("user_list_liked".localized, for: .normal)
			btnLike.isEnabled = false
		}
		
		lblUsername.text = currentUser.username
		lblAge.text = currentUser.getAgeString()
		lblFavInstrument.text = currentUser.favouriteInstrument
		if (currentUser.aboutme != "") {
			lblAboutMe.text = currentUser.aboutme
		} else {
			lblAboutMe.text = "about_me".localized
		}

		let appDelegate = (UIApplication.shared.delegate as! AppDelegate)

		if let userLocation = appDelegate.lastKnownLocation {
			lblDistance.text = currentUser.getDistanceString(between: userLocation)
		} else {
			lblDistance.text = currentUser.getDistanceString()
		}

		lblPercentage.text = "\(currentUser.percentage)%"

		
		var instrumentString = ""
		for instrument in currentUser.instruments {
			 instrumentString += instrument
			if currentUser.instruments.index(of: instrument) !=
				currentUser.instruments.count-1 {
				instrumentString += "\n"
			}
		}
		lblInstrumentList.numberOfLines = currentUser.instruments.count
		lblInstrumentList.text = instrumentString
		
		var genreString = ""
		for genre in currentUser.genres {
			genreString += genre
			if currentUser.genres.index(of: genre) !=
				currentUser.genres.count-1 {
				genreString += "\n"
			}
		}
		
		lblGenresList.numberOfLines = currentUser.genres.count
		lblGenresList.text = genreString
	}

}

extension UserDetailsViewController: RemoteImageViewDelegate {
	func didFinishLoading() {
		self.actIndicator.stopAnimating()
	}

	func imageWillLoad() {
		self.actIndicator.startAnimating()
	}
}
