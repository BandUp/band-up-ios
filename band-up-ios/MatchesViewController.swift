//
//  MatchesViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 18.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit

class MatchesViewController: UIViewController {

	// MARK: - IBOutlets
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var lblError: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	// MARK: - Variables
	var matchedUsers = [User]()
	var refreshControl = UIRefreshControl()

	// MARK: - UIViewController Overrides
	override func viewDidLoad() {
		super.viewDidLoad()

		// Register the tableView for 3D Touch
		registerForPreviewing(with: self, sourceView: tableView)

		refreshControl.tintColor = UIColor.bandUpYellow
		refreshControl.addTarget(self, action: #selector(loadMatches), for: .valueChanged)

		if #available(iOS 10.0, *) {
			tableView.refreshControl = refreshControl
		} else {
			tableView.backgroundView = refreshControl
		}

		loadMatches()
	}

	override func viewWillAppear(_ animated: Bool) {
		let selectedIndexPath = tableView.indexPathForSelectedRow
		if let indexPath = selectedIndexPath {
			tableView.deselectRow(at: indexPath, animated: true)
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func loadMatches() {
		BandUpAPI.sharedInstance.matches.load().onSuccess { (response) in
			self.stopActivityIndicators()
			self.tableView.isHidden = false

			if response.jsonArray.count == 0 {
				self.displayError("matches_no_users".localized)
				return
			}

			self.matchedUsers = []
			for user in response.jsonArray {
				if let jsonUser = user as? NSDictionary {
					self.matchedUsers.append(User(jsonUser))
				}
			}
			self.tableView.reloadData()

		}.onFailure { (error) in
			self.stopActivityIndicators()
			self.displayError("matches_failed_to_fetch".localized)

		}
	}

	func displayError(_ text:String) {
		self.lblError.text = text
		self.tableView.isHidden = true
		self.lblError.isHidden = false
	}

	func stopActivityIndicators() {
		self.activityIndicator.stopAnimating()
		refreshControl.endRefreshing()
	}

}

extension MatchesViewController: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return matchedUsers.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "match_user_cell", for: indexPath) as? MatchesTableViewCell else {
			return UITableViewCell()
		}
		cell.user = matchedUsers[indexPath.row]
		return cell
	}
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let user = matchedUsers[indexPath.row]
        let storyboard = UIStoryboard(name: Storyboard.matches, bundle: Bundle.main)
		if let viewController =  storyboard.instantiateViewController(withIdentifier: ControllerID.chat) as? ChatViewController {
			viewController.user = user
			self.navigationController?.pushViewController(viewController, animated: true)
		}
    }

}

// MARK: - 3D touch Implementation
extension MatchesViewController: UIViewControllerPreviewingDelegate {

	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
		
		let storyboard = UIStoryboard(name: Storyboard.matches, bundle: Bundle.main)
		let storyController = storyboard.instantiateViewController(withIdentifier: ControllerID.chat)
		guard let viewController =  storyController as? ChatViewController else { return nil }
		
		viewController.user = matchedUsers[indexPath.row]
		
		let cellRect = tableView.rectForRow(at: indexPath)
		let sourceRect = previewingContext.sourceView.convert(cellRect, from: tableView)
		previewingContext.sourceRect = sourceRect
		
		return viewController

	}
	
	func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
		show(viewControllerToCommit, sender: self)
	}

}
