//
//  DrawerViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 16.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit
import KYDrawerController

class DrawerViewController: UIViewController {

	// MARK: - IBOutlets
	@IBOutlet weak var lblUsername: UILabel!
	@IBOutlet weak var imgUserImage: UIImageView!
	@IBOutlet weak var lblFavInstrument: UILabel!
	@IBOutlet weak var tableView: UITableView!

	// MARK: - Variables
	let listItems = [
		DrawerItem(id: "main_nav_near_me",    name: "Near Me"),
		DrawerItem(id: "main_nav_my_profile", name: "My Profile"),
		DrawerItem(id: "main_nav_matches",    name: "Matches/Chat"),
		DrawerItem(id: "main_nav_settings",   name: "Settings"),
		DrawerItem(id: "main_nav_upcoming",   name: "Coming Soon"),
		DrawerItem(id: "main_nav_log_out",    name: "Log Out")
	]
	
	let ITEM_IMAGE_TAG = 1
	let ITEM_NAME_TAG = 2
	
	var currentUser = User()

	// MARK: - UIViewController Overrides
	override func viewDidLoad() {
		super.viewDidLoad()
		if let parent = parent as? KYDrawerController {
			if let mainViewController = parent.mainViewController.childViewControllers[0] as? MainScreenViewController {
				mainViewController.profileViewController?.delegate = self
			}
		}
		
		for i in listItems {
			i.name = i.id.localized
		}
		BandUpAPI.sharedInstance.profile.load().onSuccess({ (response) in
			self.currentUser = User(response.jsonDict as NSDictionary)
			self.populateUser()
		}).onFailure({ (error) in
			
		})
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - IBActions
	@IBAction func tappedProfile(_ sender: UIButton) {
		self.displayView("main_nav_my_profile", drawerAnimated: true)
	}

	// MARK: - Helper Functions
	func populateUser() {
		self.lblUsername.text = currentUser.username
		self.lblFavInstrument.text = currentUser.favouriteInstrument

		imgUserImage.image = nil

		if let checkedUrl = URL(string: currentUser.image.url) {
			self.downloadImage(url: checkedUrl, imageView: imgUserImage)
		} else {
			imgUserImage.image = #imageLiteral(resourceName: "ProfilePlaceholder")

		}

	}

	func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
		URLSession.shared.dataTask(with: url) { (data, response, error) in
			completion(data, response, error)
			}.resume()
	}
	
	func downloadImage(url: URL, imageView: UIImageView) {
		getDataFromUrl(url: url) { (data, response, error)  in
			guard let data = data, error == nil else { return }
			DispatchQueue.main.async { () -> Void in
				imageView.image = UIImage(data: data)
			}
		}
	}

	func getIndexPath(of item: String) -> IndexPath? {
		for (index, listItem) in listItems.enumerated() {
			if listItem.id == item {
				return IndexPath(row: index, section: 0)
			}
		}
		return nil
	}

	func selectControllerWith(id: String) {
		if let index = getIndexPath(of: id) {
			tableView.selectRow(at: index, animated: false, scrollPosition: UITableViewScrollPosition.top)
		}
	}

	func displayView(_ id: String, drawerAnimated: Bool) {
		guard let drawer = self.parent as? KYDrawerController else {
			return
		}

		guard let mainController = drawer.mainViewController.childViewControllers[0] as? MainScreenViewController else {
			return
		}

		mainController.updateView(row: id)
		drawer.setDrawerState(.closed, animated: drawerAnimated)
	}
}

// MARK: - Extensions
// MARK: ProfileViewDelegate Implementation
extension DrawerViewController: ProfileViewDelegate {
	func update(user: User) {
		currentUser = user
		populateUser()
	}
}

// MARK: UITableView Implementation
extension DrawerViewController: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return listItems.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "drawerCell", for: indexPath)

		if let itemName = cell.viewWithTag(ITEM_NAME_TAG) as? UILabel {
			itemName.text = listItems[indexPath.row].name
		}
		
		let colorView = UIView()
		colorView.backgroundColor = UIColor.bandUpDarkYellow
		cell.selectedBackgroundView = colorView
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.displayView(listItems[indexPath.row].id, drawerAnimated: true)
	}
}
