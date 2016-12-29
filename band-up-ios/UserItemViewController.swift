//
//  UserItemViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 18.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit
import Siesta

class UserItemViewController: UIViewController {

	@IBOutlet weak var lblGenre: UILabel!
	@IBOutlet weak var lblAge: UILabel!
	@IBOutlet weak var lblPercentage: UILabel!
	@IBOutlet weak var lblDistance: UILabel!
	@IBOutlet weak var lblFavouriteInstrument: UILabel!
	@IBOutlet weak var imgUserImage: UIImageView!
	@IBOutlet weak var btnLike: UIButton!
	
	@IBOutlet weak var btnDetails: UIButton!
	
	@IBOutlet weak var lblUsername: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		btnLike.layer.cornerRadius = 15;
		btnDetails.layer.cornerRadius = 15;
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		bandUpAPI.nearby.loadIfNeeded()?.onSuccess({ (response) in
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			print(response.jsonArray[0])
			// Go through all of the setup items in the response
			if let itemDict = response.jsonArray[0] as? NSDictionary {
				let user = User(itemDict)
				
				if let checkedUrl = URL(string: user.image.url) {
					self.imgUserImage.contentMode = .scaleAspectFill
					self.downloadImage(url: checkedUrl)
				}
				
				// All is well.
				// Create a new object and unwrap the data into it.
				self.lblUsername.text = user.username
				self.lblFavouriteInstrument.text = user.favouriteInstrument
				self.lblPercentage.text = String(format:"\(user.percentage)%%")
				self.lblDistance.text = String(format:"%.0f km away from you", user.distance)
				
				if (user.genres.count > 0) {
					self.lblGenre.text = user.genres[0]
				} else {
					self.lblGenre.text = "No Genre"
				}
				
				self.lblAge.text = String(format:"\(user.getAge()) years old")
			}

		}).onFailure({ (error) in
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			print("ERROR")
			print(error)
		})
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		URLSession.shared.dataTask(with: url) {
			(data, response, error) in
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			completion(data, response, error)
			}.resume()
	}
	
	func downloadImage(url: URL) {
		getDataFromUrl(url: url) { (data, response, error)  in
			guard let data = data, error == nil else { return }
			DispatchQueue.main.async() { () -> Void in
				self.imgUserImage.image = UIImage(data: data)
			}
		}
	}
	
	
}
