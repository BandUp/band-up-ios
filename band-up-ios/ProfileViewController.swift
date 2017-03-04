//
//  ProfileViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 18.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit

protocol ProfileViewDelegate: class {
	func update(user: User)
}

class ProfileViewController: UIViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var viewActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var imgProfileImage: RemoteImageView!
	@IBOutlet weak var lblUsername: UILabel!
	@IBOutlet weak var lblAge: UILabel!
	@IBOutlet weak var lblFavInstrument: UILabel!
	@IBOutlet weak var lblInstrumentList: UILabel!
	@IBOutlet weak var lblGenreList: UILabel!
	@IBOutlet weak var lblAboutMe: UILabel!
	@IBOutlet weak var lblError: UILabel!

	// MARK: - Variables
	var currentUser : User?
	weak var delegate : ProfileViewDelegate?

	// MARK: - UIViewController Overrides
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(someAction))

		if currentUser == nil {
			self.parent?.navigationItem.rightBarButtonItem?.isEnabled = false

			BandUpAPI.sharedInstance.profile.load().onSuccess({ (response) in
				self.parent?.navigationItem.rightBarButtonItem?.isEnabled = true
				self.viewActivityIndicator.stopAnimating()
				self.currentUser = User(response.jsonDict as NSDictionary)
				self.populateUser()
				self.scrollView.isHidden = false
				self.lblError.isHidden = true
			}).onFailure({ (error) in
				self.parent?.navigationItem.rightBarButtonItem?.isEnabled = true
				self.viewActivityIndicator.stopAnimating()
				self.scrollView.isHidden = true
				self.lblError.text = "profile_fetch_error".localized
				self.lblError.isHidden = false
			})
		}

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - Helper Functions
	func populateUser() {
		guard let currentUser = currentUser else {
			return
		}

		self.imgProfileImage.delegate = self
		self.imgProfileImage.placeholderImage = #imageLiteral(resourceName: "ProfilePlaceholder")
		self.imgProfileImage.imageURL = URL(string: currentUser.image.url)

		lblUsername.text = currentUser.username
		lblAge.text = currentUser.getAgeString()
		lblFavInstrument.text = currentUser.favouriteInstrument
		if currentUser.aboutme != "" {
			lblAboutMe.text = currentUser.aboutme
		} else {
			lblAboutMe.text = "about_me".localized
		}
		
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
		
		lblGenreList.numberOfLines = currentUser.genres.count
		lblGenreList.text = genreString
	}

	public func someAction() {
		guard let currentUser = currentUser else { return }
		if let profileImage = imgProfileImage.image {
			currentUser.image.image = profileImage
		}
		let storyboard = UIStoryboard(name: Storyboard.profile, bundle: Bundle.main)

		if let viewController =  storyboard.instantiateViewController(withIdentifier: ControllerID.editProfile) as? EditProfileViewController {
			viewController.user = currentUser
			viewController.delegate = self
			self.present(viewController, animated: true, completion: nil)
		}

	}
}
// MARK: - Extensions
extension ProfileViewController: EditProfileViewControllerDelegate {
	func userUpdated(_ newUser: User) {
		self.currentUser = newUser
		populateUser()
	}
}

// MARK: RemoteImageViewDelegate Implementation
extension ProfileViewController: RemoteImageViewDelegate {
	func didFinishLoading() {
		self.imageActivityIndicator.stopAnimating()
	}

	func imageWillLoad() {
		self.imageActivityIndicator.startAnimating()
	}
}
