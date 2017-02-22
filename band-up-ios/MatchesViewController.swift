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
		
		registerForPreviewing(with: self, sourceView: tableView)
		
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		BandUpAPI.sharedInstance.matches.loadIfNeeded()?.onSuccess({ (response) in
			self.activityIndicator.stopAnimating()
			self.tableView.isHidden = false;
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			if (response.jsonArray.count == 0) {
				self.activityIndicator.stopAnimating()
				self.lblError.text = NSLocalizedString("matches_no_users", comment: "Displayed on the matches screen.")
				self.tableView.isHidden = true
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
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			self.activityIndicator.stopAnimating()
			self.tableView.isHidden = true
			self.lblError.text = NSLocalizedString("matches_failed_to_fetch", comment: "Error displayed on the matches screen.")
			self.lblError.isHidden = false
		})
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
			self.downloadImage(url: checkedUrl, imageView: imgUserImage)
		} else {
			imgUserImage.image = #imageLiteral(resourceName: "ProfilePlaceholder")
			
		}
		let colorView = UIView()
		colorView.backgroundColor = UIColor.darkGray
		cell.selectedBackgroundView = colorView
		return cell
	}
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let user = matchedUsers[indexPath.row]
        let storyboard = UIStoryboard(name: "MatchesView", bundle: Bundle.main)
        let viewController =  storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        viewController.user = user
		
        self.navigationController?.pushViewController(viewController, animated: true)
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
	func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
		selectedCell.contentView.backgroundColor = UIColor.darkGray

	}
	func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		let cellToDeSelect:UITableViewCell = tableView.cellForRow(at: indexPath)!
		cellToDeSelect.contentView.backgroundColor = UIColor.clear
	}
}

extension MatchesViewController: UIViewControllerPreviewingDelegate {
	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
		
		let storyboard = UIStoryboard(name: "MatchesView", bundle: Bundle.main)
		let viewController =  storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
		
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
