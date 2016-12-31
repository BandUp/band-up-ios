//
//  UserDetailsViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 18.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit

class UserDetailsViewController: UIViewController {
	
	@IBOutlet weak var imgUserImage: UIImageView!
	@IBOutlet weak var lblFavInstrument: UILabel!
	@IBOutlet weak var actIndicator: UIActivityIndicatorView!
	@IBOutlet weak var lblAge: UILabel!
	@IBOutlet weak var lblUsername: UILabel!
	
	var currentUser = User()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		populateUser()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
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
		lblFavInstrument.text = currentUser.favouriteInstrument
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
