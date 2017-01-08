//
//  UpcomingViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 18.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit

class UpcomingViewController: UIViewController {
	var upcomingFeatures = [String]()
	override func viewDidLoad() {
		super.viewDidLoad()
		upcomingFeatures.append("Share found users to friends via social media")
		upcomingFeatures.append("Band Start-Up: Support for upcoming bands")
		upcomingFeatures.append("Concert Calendar")
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
}

extension UpcomingViewController: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return upcomingFeatures.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "upcoming_feature_cell", for: indexPath)
		let label = cell.viewWithTag(1) as! UILabel
		label.text = upcomingFeatures[indexPath.row]
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
}
