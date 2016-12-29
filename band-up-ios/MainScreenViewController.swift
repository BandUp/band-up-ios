//
//  MainScreenViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 16.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit
import KYDrawerController

class MainScreenViewController: UIViewController {
	
	@IBOutlet weak var viewContainer: UIView!
	
	var currentViewController = UIViewController()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let bandUpColor = UIColor (colorLiteralRed: 255/255, green: 211/255, blue: 2/255, alpha: 1);
		let titleDict: NSDictionary = [NSForegroundColorAttributeName: bandUpColor]
		self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : Any]
		currentViewController = userItemViewController
		add(asChildViewController: currentViewController)
	}
	
	
	@IBAction func didTapOpenDrawer(_ sender: Any) {
		if let drawerController = navigationController?.parent as? KYDrawerController {
			drawerController.setDrawerState(.opened, animated: true)
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	public lazy var profileViewController: ProfileViewController = {
		
		let storyboard = UIStoryboard(name: "MainScreen", bundle: Bundle.main)
		
		var viewController =  storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
		
		return viewController
	}()
	
	public lazy var userItemViewController: UserItemViewController = {
		
		let storyboard = UIStoryboard(name: "MainScreen", bundle: Bundle.main)
		
		var viewController =  storyboard.instantiateViewController(withIdentifier: "UserListViewController") as! UserItemViewController
		
		return viewController
	}()
	
	public lazy var matchesViewController: MatchesViewController = {
		
		let storyboard = UIStoryboard(name: "MainScreen", bundle: Bundle.main)
		
		var viewController =  storyboard.instantiateViewController(withIdentifier: "MatchesViewController") as! MatchesViewController
		
		return viewController
	}()
	
	public lazy var settingsViewController: SettingsViewController = {
		
		let storyboard = UIStoryboard(name: "MainScreen", bundle: Bundle.main)
		
		var viewController =  storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
		
		return viewController
	}()
	
	public lazy var upcomingViewController: UpcomingViewController = {
		
		let storyboard = UIStoryboard(name: "MainScreen", bundle: Bundle.main)
		
		var viewController =  storyboard.instantiateViewController(withIdentifier: "UpcomingViewController") as! UpcomingViewController
		
		return viewController
	}()

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
		
		switch row {
		case "nav_near_me":
			self.remove(asChildViewController: currentViewController)
			self.add(asChildViewController: userItemViewController)
			currentViewController = userItemViewController
			self.title = "Musicians Near You"
			break
		case "nav_my_profile":
			self.remove(asChildViewController: currentViewController)
			self.add(asChildViewController: profileViewController)
			currentViewController = profileViewController
			self.title = "My Profile"
			break
		case "nav_matches":
			self.remove(asChildViewController: currentViewController)
			self.add(asChildViewController: matchesViewController)
			currentViewController = matchesViewController
			self.title = "Matches"
			break
		case "nav_settings":
			self.remove(asChildViewController: currentViewController)
			self.add(asChildViewController: settingsViewController)
			currentViewController = settingsViewController
			self.title = "Settings"
			break
		case "nav_upcoming":
			self.remove(asChildViewController: currentViewController)
			self.add(asChildViewController: upcomingViewController)
			currentViewController = upcomingViewController
			self.title = "Coming Soon"
			break
		case "nav_log_out":
			break
		default:
			break
		}
	}
}

