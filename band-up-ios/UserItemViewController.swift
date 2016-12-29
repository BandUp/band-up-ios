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
		
		bandUpAPI.nearby.loadIfNeeded()?.onSuccess({ (response) in
			// Go through all of the setup items in the response
			let itemDict = response.jsonArray[0] as? NSDictionary
			print(response.jsonArray[0])
			// If it isn't a dictionary, then skip it.
			// Something is broken.
			if (itemDict == nil) {
				return
			}
				
			// Now we are sure we have a dictionary
			// Unwrap it and get the strings.
			let _username   = itemDict!["username"] as? String
			let _favInstrument = itemDict!["favoriteinstrument"] as? String
			let _percentage = itemDict!["percentage"] as? Int
			let _imgUrl = itemDict!["image"] as? NSDictionary
			
			if (_imgUrl != nil) {
				
				if let checkedUrl = URL(string: _imgUrl!["url"] as! String) {
					self.imgUserImage.contentMode = .scaleAspectFill
					self.downloadImage(url: checkedUrl)
				}
			}
				
			// If we don't find data, don't add it.
			// This is ugly. Will need to refactor.
			if (_username == nil || _favInstrument == nil || _percentage == nil) {
				return
			}
			// All is well.
			// Create a new object and unwrap the data into it.
			self.lblUsername.text = _username
			self.lblFavouriteInstrument.text = _favInstrument
			let bla = String(format:"\(_percentage!)%%")
			self.lblPercentage.text = bla

			print(response.jsonArray.capacity)
			//self?.lblUsername.text = user["username"] as? String

		}).onFailure({ (error) in
			print("ERROR")
			print(error)
		})
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
	
	func downloadImage(url: URL) {
		print("Download Started")
		getDataFromUrl(url: url) { (data, response, error)  in
			guard let data = data, error == nil else { return }
			print(response?.suggestedFilename ?? url.lastPathComponent)
			print("Download Finished")
			DispatchQueue.main.async() { () -> Void in
				self.imgUserImage.image = UIImage(data: data)
			}
		}
	}
	
	
}
