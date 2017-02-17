//
//  AppDelegate.swift
//  band-up-ios
//
//  Created by Bergþór on 18.11.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit
import KYDrawerController


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		//var shouldPerformAdditionalDelegateHandling = true

		// If a shortcut was launched, display its information and take the appropriate action
		if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {

			launchedShortcutItem = shortcutItem

			// This will block "performActionForShortcutItem:completionHandler" from being called.
			//shouldPerformAdditionalDelegateHandling = false
		}

		UIApplication.shared.statusBarStyle = .lightContent

		// set up your background color view
		let colorView = UIView()
		colorView.backgroundColor = UIColor.darkGray
		
		// use UITableViewCell.appearance() to configure
		// the default appearance of all UITableViewCells in your app
		UITableViewCell.appearance().selectedBackgroundView = colorView

		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //SocketIOManager.sharedInstance.closeConnection()
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //SocketIOManager.sharedInstance.establishConnection()
		guard let shortcut = launchedShortcutItem else { return }

		_ = handleShortCutItem(shortcutItem: shortcut)

		launchedShortcutItem = nil
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		// Saves changes in the application's managed object context before the application terminates.
	}

	var launchedShortcutItem: UIApplicationShortcutItem?
	func handleShortCutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
		var handled = false

		// Verify that the provided `shortcutItem`'s `type` is one handled by the application.

		guard let shortCutType = shortcutItem.type as String? else { return false }

		switch (shortCutType) {
		case "com.melodies.bandup.profile":
			// Handle shortcut 1 (static).
			if window?.rootViewController is KYDrawerController {
				let drawcont = (window?.rootViewController as! KYDrawerController)
				let nav = drawcont.mainViewController as! UINavigationController
				let cont = nav.viewControllers.first as! MainScreenViewController

				cont.updateView(row: "main_nav_my_profile")
			}
			handled = true
			break
		case "com.melodies.bandup.matches":
			// Handle shortcut 1 (static).
			if window?.rootViewController is KYDrawerController {
				let drawcont = (window?.rootViewController as! KYDrawerController)
				let nav = drawcont.mainViewController as! UINavigationController
				let cont = nav.topViewController as! MainScreenViewController

				cont.updateView(row: "main_nav_matches")
			}
			handled = true
			break
		default:
			break
		}
		return handled
	}

	/*
	Called when the user activates your application by selecting a shortcut on the home screen, except when
	application(_:,willFinishLaunchingWithOptions:) or application(_:didFinishLaunchingWithOptions) returns `false`.
	You should handle the shortcut in those callbacks and return `false` if possible. In that case, this
	callback is used if your application is already launched in the background.
	*/
	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		let handledShortCutItem = handleShortCutItem(shortcutItem: shortcutItem)

		completionHandler(handledShortCutItem)
	}

	func showLoginScreen() {
		let storyboard = UIStoryboard(name: "Setup", bundle: Bundle.main)
		let vc = storyboard.instantiateInitialViewController()
		(UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = vc

	}
}

