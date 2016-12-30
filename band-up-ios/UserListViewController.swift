//
//  UserListPageViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 29.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit

class UserListViewController: UIViewController {

	@IBOutlet weak var userCollectionView: UICollectionView!
	@IBOutlet weak var lblError: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	let IMG_IMAGE_TAG      = 9
	let LBL_USERNAME_TAG   = 1
	let LBL_INSTRUMENT_TAG = 2
	let LBL_DISTANCE_TAG   = 3
	let LBL_PERCENTAGE_TAG = 4
	let LBL_AGE_TAG        = 5
	let LBL_GENRE_TAG      = 6
	let BTN_DETAILS_TAG    = 7
	let BTN_LIKE_TAG       = 8
	let ACT_INDICATOR_TAG  = 10
	
	var userArray: [User] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()

		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		
		bandUpAPI.nearby.loadIfNeeded()?.onSuccess({ (response) in
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			self.activityIndicator.stopAnimating()
			for user in response.jsonArray {
				if let jsonUser = user as? NSDictionary {
					self.userArray.append(User(jsonUser))
				}
			}
			
			self.userCollectionView.reloadData()
			
		}).onFailure({ (error) in
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			self.activityIndicator.stopAnimating()
			print("ERROR")
			print(error)
		})
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

extension UserListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return userArray.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let currentUser = userArray[indexPath.row]
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "user_item_cell", for: indexPath)
		
		let imgUserImage  = cell.viewWithTag(IMG_IMAGE_TAG) as! UIImageView
		let lblUsername   = cell.viewWithTag(LBL_USERNAME_TAG) as! UILabel
		let lblInstrument = cell.viewWithTag(LBL_INSTRUMENT_TAG) as! UILabel
		let lblDistance   = cell.viewWithTag(LBL_DISTANCE_TAG) as! UILabel
		let lblPercentage = cell.viewWithTag(LBL_PERCENTAGE_TAG) as! UILabel
		let lblAge        = cell.viewWithTag(LBL_AGE_TAG) as! UILabel
		let lblGenre      = cell.viewWithTag(LBL_GENRE_TAG) as! UILabel
		let actIndicator  = cell.viewWithTag(ACT_INDICATOR_TAG) as! UIActivityIndicatorView
		
		//let btnDetails    = cell.viewWithTag(BTN_DETAILS_TAG) as! UIButton
		//let btnLike       = cell.viewWithTag(BTN_LIKE_TAG) as! UIButton
		
		imgUserImage.image = nil
		if let checkedUrl = URL(string: currentUser.image.url) {
			imgUserImage.contentMode = .scaleAspectFill
			self.downloadImage(url: checkedUrl, imageView: imgUserImage, activityIndicator: actIndicator)
		} else {
			imgUserImage.image = UIImage(named: "defaultmynd")
		}
		
		lblUsername.text = currentUser.username
		lblPercentage.text = String(format:"\(currentUser.percentage)%%")
		lblDistance.text = String(format:"%.0f km away from you", currentUser.distance)
		
		if (currentUser.favouriteInstrument == "") {
			if (currentUser.instruments.count > 0) {
				lblInstrument.text = currentUser.instruments[0]
			} else {
				lblInstrument.text = "No Instrument"
			}
		} else {
			lblInstrument.text = currentUser.favouriteInstrument
		}
		
		if (currentUser.genres.count > 0) {
			lblGenre.text = currentUser.genres[0]
		} else {
			lblGenre.text = "No Genre"
		}
		
		lblAge.text = String(format:"\(currentUser.getAge()) years old")

		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView,
	                    layout collectionViewLayout: UICollectionViewLayout,
	                    sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		return CGSize(width: view.frame.width, height: view.frame.height)
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
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
