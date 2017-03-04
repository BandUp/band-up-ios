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
		let storyboard = UIStoryboard(name: Storyboard.setup, bundle: Bundle.main)
		let vc = storyboard.instantiateInitialViewController()
		if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
			appDelegate.window?.rootViewController = vc
		} else {
			print("Couldn't find AppDelegate")
		}
	}
	
	func startSetup() {
		let storyboard = UIStoryboard(name: Storyboard.setup, bundle: Bundle.main)
		if let vc = storyboard.instantiateViewController(withIdentifier: ControllerID.setup) as? SetupViewController {
			vc.setupViewObject = Constants.completeSetup
			let navController = UINavigationController(rootViewController: vc)
			if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
				appDelegate.window?.rootViewController = navController
			} else {
				print("Couldn't find AppDelegate")
			}
		}
	}
	
	func startMain() {
		let storyboard = UIStoryboard(name: Storyboard.drawer, bundle: Bundle.main)
		let vc = storyboard.instantiateInitialViewController()
		if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
			appDelegate.window?.rootViewController = vc
		} else {
			print("Couldn't find AppDelegate")
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let uDef = UserDefaults.standard
		guard let storedHeaders = uDef.dictionary(forKey: DefaultsKeys.headers) as? [String:String] else {
			self.startLoginScreen()
			return
		}

		if storedHeaders[BandUpAPI.cookieKey] != nil {
			
			if UserDefaults.standard.object(forKey: DefaultsKeys.finishedSetup) == nil {
				BandUpAPI.sharedInstance.isLoggedIn.request(.get).onSuccess { (response) in
					print(response)
					guard let loggedIn = response.jsonDict["isLoggedIn"] as? Bool else {
						self.startLoginScreen()
						return
					}
					
					guard let finishedSetup = response.jsonDict["hasFinishedSetup"] as? Bool else {
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
