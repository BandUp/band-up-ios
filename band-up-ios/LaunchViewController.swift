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
		let storyboard = UIStoryboard(name: "Setup", bundle: Bundle.main)
		let vc = storyboard.instantiateViewController(withIdentifier: "SetupViewController") as! SetupViewController
		vc.setupViewObject = Constants.completeSetup
		let navController = UINavigationController(rootViewController: vc)
		(UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = navController
	}
	
	func startMain() {
		let storyboard = UIStoryboard(name: "DrawerView", bundle: Bundle.main)
		let vc = storyboard.instantiateInitialViewController()
		(UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = vc
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let uDef = UserDefaults.standard
		guard let storedHeaders = uDef.dictionary(forKey: DefaultsKeys.headers) else {
			self.startLoginScreen()
			return
		}
		
		if (storedHeaders as! [String:String])[BandUpAPI.cookieKey] != nil {
			
			if UserDefaults.standard.object(forKey: DefaultsKeys.finishedSetup) == nil {
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
					
					uDef.set(finishedSetup, forKey: DefaultsKeys.finishedSetup)
					
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
			} else {
				if UserDefaults.standard.bool(forKey: DefaultsKeys.finishedSetup) {
					self.startMain()
				} else {
					
					self.startSetup()
				}
			}
			return
		} else {
			self.startLoginScreen()
			return
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
