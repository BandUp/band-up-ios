//
//  UserDetailsViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 18.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit

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
	@IBOutlet weak var imgUserImage: UIImageView!
	@IBOutlet weak var actIndicator: UIActivityIndicatorView!
	@IBOutlet weak var btnLike: UIBigButton!
	
	// MARK: - Variables
	var currentUser = User()
	
	// MARK: - Overridden Functions
	override func viewDidLoad() {
		super.viewDidLoad()
		populateUser()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.title = NSLocalizedString("main_title_user_details", comment: "Title of the User Details screen.")
		populateUser()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - IBActions
	@IBAction func didClickLike(_ sender: UIBigButton) {
		
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		
		bandUpAPI.like.request(.post, json: ["userID": self.currentUser.id]).onSuccess { (response) in
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			
			if let isMatch = response.jsonDict["isMatch"] as? Bool {
				self.currentUser.isLiked = true
				sender.setTitle(NSLocalizedString("user_list_liked", comment: "Text on the green like button"), for: .normal)
				sender.isEnabled = false
				
				if isMatch {
					sender.setTitle("Matched", for: .normal)
				}
			}
			}.onFailure { (error) in
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
		}
	}
	
	// MARK: - Helper Functions
	func populateUser() {
		imgUserImage.image = nil
		
		if let checkedUrl = URL(string: currentUser.image.url) {
			self.downloadImage(url: checkedUrl, imageView: imgUserImage, activityIndicator: actIndicator)
		} else {
			actIndicator.stopAnimating()
			imgUserImage.image = #imageLiteral(resourceName: "ProfilePlaceholder")
			
		}
		
		if (currentUser.isLiked) {
			btnLike.setTitle(NSLocalizedString("user_list_liked", comment: "Text on the green like button"), for: .normal)
			btnLike.isEnabled = false
		}
		
		lblUsername.text = currentUser.username
		lblAge.text = "\(currentUser.getAge()) years old"
		lblFavInstrument.text = currentUser.favouriteInstrument
		if (currentUser.aboutme != "") {
			lblAboutMe.text = currentUser.aboutme
		} else {
			lblAboutMe.text = NSLocalizedString("about_me", comment: "About Me string displayed on the profiles")
		}
		
		lblDistance.text = String(format:"%.0f km away from you", currentUser.distance)
		
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
}
