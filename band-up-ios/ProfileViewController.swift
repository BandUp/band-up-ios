//
//  ProfileViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 18.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
	
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var viewActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var imgProfileImage: UIImageView!
	@IBOutlet weak var lblUsername: UILabel!
	@IBOutlet weak var lblAge: UILabel!
	@IBOutlet weak var lblFavInstrument: UILabel!
	@IBOutlet weak var lblInstrumentList: UILabel!
	@IBOutlet weak var lblGenreList: UILabel!
	@IBOutlet weak var lblAboutMe: UILabel!
	@IBOutlet weak var lblError: UILabel!
	
	var currentUser = User()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(someAction))
		self.parent?.navigationItem.rightBarButtonItem?.isEnabled = false
		bandUpAPI.profile.load().onSuccess({ (response) in
			self.parent?.navigationItem.rightBarButtonItem?.isEnabled = true
			self.viewActivityIndicator.stopAnimating()
			self.currentUser = User(response.jsonDict as NSDictionary)
			self.populateUser()
			self.scrollView.isHidden = false
		}).onFailure({ (error) in
			print("FAILURE")
			self.viewActivityIndicator.stopAnimating()
			self.scrollView.isHidden = true
			self.lblError.text = "Could not get your profile"
			self.lblError.isHidden = false
		})
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(someAction))
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Helper Functions
	func populateUser() {
		imgProfileImage.image = nil
		
		if let checkedUrl = URL(string: currentUser.image.url) {
			imgProfileImage.contentMode = .scaleAspectFill
			self.downloadImage(url: checkedUrl, imageView: imgProfileImage, activityIndicator: imageActivityIndicator)
		} else {
			imageActivityIndicator.stopAnimating()
			imgProfileImage.image = UIImage(named: "defaultmynd")
			
		}
		
		lblUsername.text = currentUser.username
		lblAge.text = "\(currentUser.getAge()) years old"
		lblFavInstrument.text = currentUser.favouriteInstrument
		if (currentUser.aboutme != "") {
			lblAboutMe.text = currentUser.aboutme
		} else {
			lblAboutMe.text = "About Me"
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
	
	func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
		URLSession.shared.dataTask(with: url) {
			(data, response, error) in
			completion(data, response, error)
			}.resume()
	}
	
	func downloadImage(url: URL, imageView: UIImageView, activityIndicator: UIActivityIndicatorView) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		activityIndicator.startAnimating()
		getDataFromUrl(url: url) { (data, response, error)  in
			guard let data = data, error == nil else { return }
			DispatchQueue.main.async() { () -> Void in
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				activityIndicator.stopAnimating()
				imageView.image = UIImage(data: data)
			}
		}
	}
	
	public func someAction() {
		let storyboard = UIStoryboard(name: "ProfileView", bundle: Bundle.main)
		
		let viewController =  storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
		viewController.user = currentUser
		self.present(viewController, animated: true, completion: nil)
	}
}
