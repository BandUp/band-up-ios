//
//  MatchesViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 18.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit

class MatchesViewController: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
	
	var matchedUsers = [User]()
	
	@IBOutlet weak var lblError: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	override func viewDidLoad() {
		super.viewDidLoad()
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		bandUpAPI.matches.loadIfNeeded()?.onSuccess({ (response) in
			self.activityIndicator.stopAnimating()
			self.tableView.isHidden = false;
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			if (response.jsonArray.count == 0) {
				self.activityIndicator.stopAnimating()
				self.lblError.text = "You haven't matched with anyone, yet."
				self.lblError.isHidden = false
				return
			}
			for user in response.jsonArray {
				if let jsonUser = user as? NSDictionary {
					self.matchedUsers.append(User(jsonUser))
				}
			}
			self.tableView.reloadData()
		}).onFailure({ (error) in
			self.activityIndicator.stopAnimating()
			self.lblError.text = "Could not get your matches"
			self.lblError.isHidden = false
		})
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
}


extension MatchesViewController: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return matchedUsers.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "match_user_cell", for: indexPath)
		let imgUserImage = cell.viewWithTag(1) as! UIImageView
		let label = cell.viewWithTag(2) as! UILabel
		label.text = matchedUsers[indexPath.row].username
		imgUserImage.image = nil
		
		if let checkedUrl = URL(string: matchedUsers[indexPath.row].image.url) {
			imgUserImage.contentMode = .scaleAspectFill
			self.downloadImage(url: checkedUrl, imageView: imgUserImage)
		} else {
			imgUserImage.image = UIImage(named: "defaultmynd")
			
		}
		return cell
	}
	
	func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
		URLSession.shared.dataTask(with: url) {
			(data, response, error) in
			completion(data, response, error)
			}.resume()
	}
	
	func downloadImage(url: URL, imageView: UIImageView) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		getDataFromUrl(url: url) { (data, response, error)  in
			guard let data = data, error == nil else { return }
			DispatchQueue.main.async() { () -> Void in
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				imageView.image = UIImage(data: data)
			}
		}
	}
}
