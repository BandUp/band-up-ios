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
	// MARK: - IBOutlets
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	// MARK: - UIViewController Overrides
	override func viewDidLoad() {
		super.viewDidLoad()
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
			return
		}

		let uDef = UserDefaults.standard
		guard let storedHeaders = uDef.dictionary(forKey: DefaultsKeys.headers) as? [String:String] else {
			appDelegate.showLoginScreen(animated: false)
			return
		}

		if storedHeaders[BandUpAPI.cookieKey] != nil {
			
			if UserDefaults.standard.object(forKey: DefaultsKeys.finishedSetup) == nil {
				BandUpAPI.sharedInstance.isLoggedIn.request(.get).onSuccess { (response) in

					guard let loggedIn = response.jsonDict["isLoggedIn"] as? Bool else {
						appDelegate.showLoginScreen(animated: false)
						return
					}
					
					guard let finishedSetup = response.jsonDict["hasFinishedSetup"] as? Bool else {
						appDelegate.showLoginScreen(animated: false)
						return
					}
					
					uDef.set(finishedSetup, forKey: DefaultsKeys.finishedSetup)
					
					if loggedIn {
						if !finishedSetup {
							appDelegate.displaySetupView()
						} else {
							appDelegate.displayMainScreenView()
						}
						
					} else {
						appDelegate.showLoginScreen(animated: false)
					}
				}.onFailure { (error) in
					appDelegate.showLoginScreen(animated: false)
				}
			} else {
				if UserDefaults.standard.bool(forKey: DefaultsKeys.finishedSetup) {
					appDelegate.displayMainScreenView()
				} else {
					
					appDelegate.displaySetupView()
				}
			}
			return
		} else {
			appDelegate.showLoginScreen(animated: false)
			return
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}
