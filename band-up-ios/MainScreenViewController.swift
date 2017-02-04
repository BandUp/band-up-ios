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
		currentViewController = userItemViewController
		add(asChildViewController: currentViewController)
		let backItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		self.navigationItem.backBarButtonItem = backItem

		self.navigationController?.navigationBar.tintColor = bandUpColor
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
		let storyboard = UIStoryboard(name: "ProfileView", bundle: Bundle.main)
		
		var viewController =  storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
		
		return viewController
	}()
	
	public lazy var userItemViewController: UserListViewController = {
		
		let storyboard = UIStoryboard(name: "UserListView", bundle: Bundle.main)
		
		var viewController =  storyboard.instantiateViewController(withIdentifier: "UserListViewController") as! UserListViewController
		
		return viewController
	}()
	
	public lazy var matchesViewController: MatchesViewController = {
		
		let storyboard = UIStoryboard(name: "MatchesView", bundle: Bundle.main)
		
		var viewController =  storyboard.instantiateViewController(withIdentifier: "MatchesViewController") as! MatchesViewController
		
		return viewController
	}()
	
	public lazy var settingsViewController: SettingsViewController = {
		
		let storyboard = UIStoryboard(name: "SettingsView", bundle: Bundle.main)
		
		var viewController =  storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
		
		return viewController
	}()
	
	public lazy var upcomingViewController: UpcomingViewController = {
		
		let storyboard = UIStoryboard(name: "UpcomingView", bundle: Bundle.main)
		
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
			self.navigationItem.rightBarButtonItem = nil
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
			self.navigationItem.rightBarButtonItem = nil
			break
		case "nav_settings":
			self.remove(asChildViewController: currentViewController)
			self.add(asChildViewController: settingsViewController)
			currentViewController = settingsViewController
			self.title = "Settings"
			self.navigationItem.rightBarButtonItem = nil
			break
		case "nav_upcoming":
			self.remove(asChildViewController: currentViewController)
			self.add(asChildViewController: upcomingViewController)
			currentViewController = upcomingViewController
			self.title = "Coming Soon"
			self.navigationItem.rightBarButtonItem = nil
			break
		case "nav_log_out":
			dismiss(animated: true, completion: nil)
			break
		default:
			break
		}
	}
	

}

