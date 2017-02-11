//
//  LaunchViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 11.2.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import Foundation
import UIKit
import Siesta

class LaunchViewController: UIViewController {
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	func startLoginScreen() {
		let storyboard = UIStoryboard(name: "Setup", bundle: Bundle.main)
		let vc = storyboard.instantiateInitialViewController()
		(UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = vc
	}
	
	func startSetup() {
		// TODO: Open the setup screen.
		startLoginScreen()
	}
	
	func startMain() {
		let storyboard = UIStoryboard(name: "DrawerView", bundle: Bundle.main)
		let vc = storyboard.instantiateInitialViewController()
		(UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = vc
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		BandUpAPI.sharedInstance.isLoggedIn.request(.get).onSuccess { (response) in
			print(response)
			guard let loggedIn = response.jsonDict["isLoggedIn"] as! Bool? else {
				self.startLoginScreen()
				return
			}
			
			guard let finishedSetup = response.jsonDict["hasFinishedSetup"] as! Bool? else {
				self.startLoginScreen()
				return
			}
			
			if loggedIn {
				if !finishedSetup {
					self.startSetup()
				} else {
					self.startMain()
				}
				
			} else {
				self.startLoginScreen()
			}
			
			
			
		}.onFailure { (error) in
			self.startLoginScreen()
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
