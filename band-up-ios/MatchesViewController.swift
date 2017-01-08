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
	override func viewDidLoad() {
		super.viewDidLoad()
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		bandUpAPI.matches.loadIfNeeded()?.onSuccess({ (response) in
			UIApplication.shared.isNetworkActivityIndicatorVisible = false

			for user in response.jsonArray {
				if let jsonUser = user as? NSDictionary {
					self.matchedUsers.append(User(jsonUser))
				}
			}
			self.tableView.reloadData()
		}).onFailure({ (error) in
			
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
		let label = cell.viewWithTag(2) as! UILabel
		label.text = matchedUsers[indexPath.row].username
		
		return cell
	}
}
