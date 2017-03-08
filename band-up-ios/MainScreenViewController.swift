//
//  MainScreenViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 16.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit
import KYDrawerController
import CoreLocation

class MainScreenViewController: UIViewController {
	// MARK: - Variables
	var currentViewController = UIViewController()

	// MARK: - UIViewController Overrides
	override func viewDidLoad() {
		super.viewDidLoad()

		let status = CLLocationManager.authorizationStatus()

		auth: if status == .authorizedWhenInUse || status == .authorizedAlways {
			guard let navigationController = navigationController else {
				break auth
			}

			guard let drawerController = navigationController.parent as? KYDrawerController else {
				break auth
			}

			if let drawerViewController = drawerController.drawerViewController as? DrawerViewController {
				guard let userItemViewController = userItemViewController else {
					return
				}
				drawerViewController.selectControllerWith(id:"main_nav_near_me")
				currentViewController = userItemViewController
				add(asChildViewController: currentViewController)
			}

		} else if status == .notDetermined {
			if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
				appDelegate.manager.requestWhenInUseAuthorization()
			}
		} else if status == .denied {
			// Display some screen that says that we need location
		} else if status == .restricted {
			// Display some screen that says that we need location but the user has restricted access.
		}

		let backItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		self.navigationItem.backBarButtonItem = backItem
		self.navigationController?.navigationBar.tintColor = UIColor.bandUpYellow
	}

	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - IBActions
	@IBAction func didTapOpenDrawer(_ sender: Any) {
		if let drawerController = navigationController?.parent as? KYDrawerController {
			drawerController.setDrawerState(.opened, animated: true)
		}
	}

	// MARK: - Lazy Variables
	public lazy var profileViewController: ProfileViewController? = {
		let storyboard = UIStoryboard(name: Storyboard.profile, bundle: Bundle.main)

		if let viewController = storyboard.instantiateViewController(withIdentifier: ControllerID.profile) as? ProfileViewController {
			return viewController
		}

		return nil
	}()
	
	public lazy var userItemViewController: UserListViewController? = {
		
		let storyboard = UIStoryboard(name: Storyboard.userList, bundle: Bundle.main)

		if let viewController = storyboard.instantiateViewController(withIdentifier: ControllerID.userList) as? UserListViewController {
			return viewController
		}

		return nil
	}()
	
	public lazy var matchesViewController: MatchesViewController? = {
		
		let storyboard = UIStoryboard(name: Storyboard.matches, bundle: Bundle.main)

		if let viewController = storyboard.instantiateViewController(withIdentifier: ControllerID.matches) as? MatchesViewController {
			return viewController
		}

		return nil
	}()
	
	public lazy var settingsViewController: SettingsViewController? = {
		
		let storyboard = UIStoryboard(name: Storyboard.settings, bundle: Bundle.main)
		
		if let viewController = storyboard.instantiateViewController(withIdentifier: ControllerID.settings) as? SettingsViewController {
			return viewController
		}

		return nil
	}()
	
	public lazy var upcomingViewController: UpcomingViewController? = {
		
		let storyboard = UIStoryboard(name: Storyboard.upcoming, bundle: Bundle.main)

		if let viewController = storyboard.instantiateViewController(withIdentifier: ControllerID.upcoming) as? UpcomingViewController {
			return viewController
		}

		return nil
	}()

	// MARK: - Helper Functions
	private func add(asChildViewController viewController: UIViewController) {
		// Add Child View Controller
		addChildViewController(viewController)
		
		// Add Child View as Subview
		view.addSubview(viewController.view)
		
		// Configure Child View
		viewController.view.frame = view.bounds
		viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		// Notify Child View Controller
		viewController.didMove(toParentViewController: self)
	}
	
	private func remove(asChildViewController viewController: UIViewController) {
		
		// Notify Child View Controller
		viewController.willMove(toParentViewController: nil)
		
		// Remove Child View From Superview
		viewController.view.removeFromSuperview()
		
		// Notify Child View Controller
		viewController.removeFromParentViewController()
		
	}
	
	public func updateView(row: String) {
		guard let drawerController = navigationController?.parent as? KYDrawerController else {
			return
		}

		guard let drawerViewController = drawerController.drawerViewController as? DrawerViewController else {
			return
		}

		switch row {
		case "main_nav_near_me":
			guard let userItemViewController = userItemViewController else {
				return
			}
			self.remove(asChildViewController: currentViewController)
			self.add(asChildViewController: userItemViewController)
			currentViewController = userItemViewController
			self.title = "main_title_user_list".localized
			self.navigationItem.rightBarButtonItem = nil
			break
		case "main_nav_my_profile":
			guard let profileViewController = profileViewController else {
				return
			}
			self.remove(asChildViewController: currentViewController)
			self.add(asChildViewController: profileViewController)
			currentViewController = profileViewController
			self.title = "main_title_my_profile".localized
			break
		case "main_nav_matches":
			guard let matchesViewController = matchesViewController else {
				return
			}
			self.remove(asChildViewController: currentViewController)
			self.add(asChildViewController: matchesViewController)
			currentViewController = matchesViewController
			self.title = "main_title_matches".localized
			self.navigationItem.rightBarButtonItem = nil
			break
		case "main_nav_settings":
			guard let settingsViewController = settingsViewController else {
				return
			}
			self.remove(asChildViewController: currentViewController)
			self.add(asChildViewController: settingsViewController)
			currentViewController = settingsViewController
			self.title = "main_title_settings".localized
			self.navigationItem.rightBarButtonItem = nil
			break
		case "main_nav_upcoming":
			guard let upcomingViewController = upcomingViewController else {
				return
			}
			self.remove(asChildViewController: currentViewController)
			self.add(asChildViewController: upcomingViewController)
			currentViewController = upcomingViewController
			self.title = "main_title_upcoming_features".localized
			self.navigationItem.rightBarButtonItem = nil
			break
		case "main_nav_log_out":
			BandUpAPI.sharedInstance.logout.request(.get).onSuccess { (response) in

				if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
					appDelegate.showLoginScreen(animated: true)
				} else {
					print("Could not find AppDelegate")
				}
			}.onFailure { (error) in
				let failAlertController = UIAlertController(title: "drawer_alert_logout_error_title".localized, message: "drawer_alert_logout_error_message".localized, preferredStyle: .alert)

				let okAction = UIAlertAction(title: "search_ok".localized, style: .default, handler: nil)

				failAlertController.addAction(okAction)
				failAlertController.preferredAction = okAction

				self.present(failAlertController, animated: true, completion: nil)
			}
			break
		default:
			break
		}

		drawerViewController.selectControllerWith(id: row)
	}
	
}
