//
//  UpcomingViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 18.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit

class UpcomingViewController: UIViewController {
	// MARK: - Variables
	var upcomingFeatures = [String]()

	// MARK: - UIViewController Overrides
	override func viewDidLoad() {
		super.viewDidLoad()
		upcomingFeatures.append(NSLocalizedString("upcoming_share_users", comment: "List item in the Upcoming Features List"))
		upcomingFeatures.append(NSLocalizedString("upcoming_rent_practice", comment: "List item in the Upcoming Features List"))
		upcomingFeatures.append(NSLocalizedString("upcoming_event_calendar", comment: "List item in the Upcoming Features List"))
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}

// MARK: - Extensions
// MARK: UITableView Implementation
extension UpcomingViewController: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return upcomingFeatures.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "upcoming_feature_cell", for: indexPath)
		if let label = cell.viewWithTag(1) as? UILabel {
			label.text = upcomingFeatures[indexPath.row]
		} else {
			print("Could not load label.")
		}

		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
}
