//
//  UserDetailsViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 18.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit

class UserDetailsViewController: UIViewController {
	@IBOutlet weak var lblAboutMe: UILabel!
	@IBOutlet weak var lblGenresList: UILabel!
	@IBOutlet weak var lblPercentage: UILabel!
	
	@IBOutlet weak var lblDistance: UILabel!
	@IBOutlet weak var imgUserImage: UIImageView!
	@IBOutlet weak var lblInstrumentList: UILabel!
	@IBOutlet weak var lblFavInstrument: UILabel!
	@IBOutlet weak var actIndicator: UIActivityIndicatorView!
	@IBOutlet weak var lblAge: UILabel!
	@IBOutlet weak var lblUsername: UILabel!
	
	var currentUser = User()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style:.plain, target:nil, action:nil)
		populateUser()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style:.plain, target:nil, action:nil)

		populateUser()
	}
	
	func populateUser() {
		imgUserImage.image = nil
		if let checkedUrl = URL(string: currentUser.image.url) {
			imgUserImage.contentMode = .scaleAspectFill
			self.downloadImage(url: checkedUrl, imageView: imgUserImage, activityIndicator: actIndicator)
		} else {
			imgUserImage.image = UIImage(named: "defaultmynd")
		}
		
		lblUsername.text = currentUser.username
		lblAge.text = "\(currentUser.getAge()) years old"
		lblFavInstrument.text = currentUser.favouriteInstrument
		if (currentUser.aboutme != "") {
			lblAboutMe.text = currentUser.aboutme
		} else {
			lblAboutMe.text = "About Me"
		}
		
		lblDistance.text = String(format:"%.0f km away from you", currentUser.distance)
		
		lblPercentage.text = "\(currentUser.percentage)%"

		
		var instrumentString = ""
		for instrument in currentUser.instruments {
			 instrumentString += "\(instrument)\n"
		}
		lblInstrumentList.numberOfLines = currentUser.instruments.count
		lblInstrumentList.text = instrumentString
		
		var genreString = ""
		for genre in currentUser.genres {
			genreString += "\(genre)\n"
		}
		lblGenresList.numberOfLines = currentUser.genres.count
		lblGenresList.text = genreString
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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
