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
	let listItems = [
		ListItem(image: "near-me-icon", name: "Near Me"),
		ListItem(image: "account",      name: "My Profile"),
		ListItem(image: "link",         name: "Matches/Chat"),
		ListItem(image: "settings",     name: "Settings"),
		ListItem(image: "arrow-right",  name: "Coming Soon"),
		ListItem(image: "logout",       name: "Log Out")
	]
	
	let ITEM_IMAGE_TAG = 1
	let ITEM_NAME_TAG = 2
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}

extension DrawerViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "drawerCell", for: indexPath)
		let itemName = cell.viewWithTag(ITEM_NAME_TAG) as! UILabel
		
		itemName.text = listItems[indexPath.row].name
		return cell
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return listItems.count
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let drawer = self.navigationController?.parent as! KYDrawerController
		let mainController = drawer.mainViewController.childViewControllers[0] as! MainScreenViewController
		mainController.updateView(row: indexPath.row)
		drawer.setDrawerState(.closed, animated: true)
	}
}

class ListItem {
	init(image : String, name: String) {
		self.name = name
		self.image = image
	}
	
	var name : String = ""
	var image : String = ""
}
