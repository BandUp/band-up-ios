//
//  AppDelegate.swift
//  band-up-ios
//
//  Created by Bergþór on 18.11.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit
import KYDrawerController
import CoreLocation
import UserNotifications
import Firebase
import Soundcloud
import GGLSignIn
import Siesta
import FacebookCore
import FacebookLogin
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	let manager = CLLocationManager()
	var locationTimer = Timer()
	var launchedShortcutItem: UIApplicationShortcutItem?
	var lastKnownLocation: CLLocation?
	var isDisplayingActivityIndicator: Bool = false

	// MARK: - Application Delegate
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {

		var handled = false
		if let sourceApp = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String! {
			if FBSDKApplicationDelegate.sharedInstance().application(UIApplication.shared, open: url, sourceApplication: sourceApp, annotation: options[UIApplicationOpenURLOptionsKey.annotation]) {
				handled = true
			}
		}

		if GIDSignIn.sharedInstance().handle(url,
											 sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
											 annotation: options[UIApplicationOpenURLOptionsKey.annotation]) {
			handled = true
		}

		return handled
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		// Set default.
		if UserDefaults.standard.object(forKey: DefaultsKeys.Settings.radius) == nil {
			UserDefaults.standard.set(Constants.defaultRadius, forKey: DefaultsKeys.Settings.radius)
		}

		if UserDefaults.standard.object(forKey: DefaultsKeys.Settings.minAge) == nil {
			UserDefaults.standard.set(Constants.minAge, forKey: DefaultsKeys.Settings.minAge)
		}

		if UserDefaults.standard.object(forKey: DefaultsKeys.Settings.maxAge) == nil {
			UserDefaults.standard.set(Constants.maxAge, forKey: DefaultsKeys.Settings.maxAge)
		}

		var configureError: NSError?

		GGLContext.sharedInstance().configureWithError(&configureError)
		assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")

		var keys: NSDictionary?

		if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
			keys = NSDictionary(contentsOfFile: path)
		}
		if let dict = keys {
			let scClient = dict["soundCloudClient"] as? String
			let scSecret = dict["soundCloudClientSecret"] as? String
			let fbAppId  = dict["facebookAppId"] as? String

			SoundcloudClient.clientIdentifier = scClient
			SoundcloudClient.clientSecret = scSecret
			SoundcloudClient.redirectURI = Constants.bandUpAddress?.absoluteString
			FBSDKSettings.setAppID(fbAppId)
		}

		// If a shortcut was launched, display its information and take the appropriate action
		if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
			launchedShortcutItem = shortcutItem
		}

		manager.delegate = self
		manager.desiredAccuracy = kCLLocationAccuracyKilometer

		// Run Request updates every x seconds.
		startLocationTimer()

		UIApplication.shared.statusBarStyle = .lightContent

		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state.
		// This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message)
		// or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks.
		// Games should use this method to pause the game.
		ChatSocket.sharedInstance.closeConnection()
		locationTimer.invalidate()
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough
		// application state information to restore your application to its current state
		// in case it is terminated later.
		// If your application supports background execution, this method is called instead of
		// applicationWillTerminate: when the user quits.
        ChatSocket.sharedInstance.closeConnection()
		locationTimer.invalidate()
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
		ChatSocket.sharedInstance.establishConnection()
		startLocationTimer()
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        ChatSocket.sharedInstance.establishConnection()
		startLocationTimer()
		guard let shortcut = launchedShortcutItem else { return }

		_ = handleShortCutItem(shortcutItem: shortcut)

		launchedShortcutItem = nil
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		// Saves changes in the application's managed object context before the application terminates.
		ChatSocket.sharedInstance.closeConnection()
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

	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

		print("Message ID \(userInfo["gcm.message_id"]!)")
		print(userInfo)
	}

	// MARK: - Helper Functions
	func handleShortCutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
		var handled = false

		// Verify that the provided `shortcutItem`'s `type` is one handled by the application.

		guard let shortCutType = shortcutItem.type as String? else { return false }

		if window?.rootViewController is KYDrawerController {
			guard let drawerController = window?.rootViewController as? KYDrawerController else {
				print("Could not find KYDrawerController")
				return false
			}

			guard let navigationController = drawerController.mainViewController as? UINavigationController else {
				print("Could not find NavigationController")
				return false
			}

			guard let mainController = navigationController.viewControllers.first as? MainScreenViewController else {
				print("Could not find MainScreenViewController")
				return false
			}

			switch shortCutType {
			case "com.melodies.bandup.profile":
				// Handle shortcut 1 (static).
				mainController.updateView(row: "main_nav_my_profile")
				drawerController.setDrawerState(.closed, animated: false)
				handled = true
				break
			case "com.melodies.bandup.matches":
				// Handle shortcut 1 (static).
				mainController.updateView(row: "main_nav_matches")
				drawerController.setDrawerState(.closed, animated: false)
				handled = true
				break
			default:
				break
			}

		} else {
			return false
		}

		return handled
	}

	func showLoginScreen(animated: Bool) {
		if window?.rootViewController is LoginViewController {
			return
		}
		let storyboard = UIStoryboard(name: Storyboard.setup, bundle: Bundle.main)
		let desiredViewController = storyboard.instantiateInitialViewController()
		if animated {

			let snapshot:UIView = (self.window?.rootViewController!.view.snapshotView(afterScreenUpdates: true))!

			self.window?.rootViewController = desiredViewController
			
			self.window?.rootViewController?.view.layer.transform = CATransform3DMakeTranslation(0.0, UIScreen.main.bounds.height, 0)
			UIView.animate(withDuration: 0.35 , delay: 0, options: [UIViewAnimationOptions.curveEaseInOut], animations: {() in
				desiredViewController?.view.layer.transform = CATransform3DMakeTranslation(0.0, 0, 0)

			}, completion: { (value: Bool) in
				snapshot.removeFromSuperview()
			})
		} else {
			window?.rootViewController = desiredViewController
		}
	}

	/**
	Displays the setup view where instruments and genres are selected with the SetupViewController.

	- returns: No return value
	*/
	func displaySetupView() {
		if window?.rootViewController is SetupViewController {
			return
		}

		let storyboard = UIStoryboard(name: Storyboard.setup, bundle: Bundle.main)
		if let vc = storyboard.instantiateViewController(withIdentifier: ControllerID.setup) as? SetupViewController {
			vc.setupViewObject = Constants.completeSetup
			let navController = UINavigationController(rootViewController: vc)
			self.window?.rootViewController = navController
		}
	}

	/**
	Displays the main screen where the user list will be shown first.

	- returns: No return value
	*/
	func displayMainScreenView() {
		if window?.rootViewController is KYDrawerController {
			return
		}

		let storyboard = UIStoryboard(name: Storyboard.drawer, bundle: Bundle.main)
		let desiredViewController = storyboard.instantiateInitialViewController()

		let snapshot:UIView = (self.window?.rootViewController!.view.snapshotView(afterScreenUpdates: true))!
		desiredViewController?.view.addSubview(snapshot)

		self.window?.rootViewController = desiredViewController

		UIView.animate(withDuration: 0.35 , delay: 0, options: [UIViewAnimationOptions.curveEaseInOut], animations: {() in
			snapshot.layer.transform = CATransform3DMakeTranslation(0.0, UIScreen.main.bounds.height, 0)
		}, completion: { (value: Bool) in
			snapshot.removeFromSuperview()
		})
	}
}

extension AppDelegate: CLLocationManagerDelegate {

	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedWhenInUse {
			manager.delegate = self
		}
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if locations.count > 0 {
			if locations[0].horizontalAccuracy < abs(1000) {
				if let lastKnownLocation = lastKnownLocation {
					for location in locations {
						if lastKnownLocation.timestamp < location.timestamp {
							self.lastKnownLocation = location
							NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NewLocation"), object: nil, userInfo: ["locations": [lastKnownLocation]])

						}
					}
				} else {
					lastKnownLocation = locations[0]
					NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NewLocation"), object: nil, userInfo: ["locations": locations])

				}
			}
		}
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

	}

	func startLocationTimer() {
		if !locationTimer.isValid {
			manager.requestLocation()
			locationTimer = Timer.scheduledTimer(timeInterval: Constants.locationUpdateRate,
			                                     target: self,
			                                     selector: #selector(self.myTimerFunc),
			                                     userInfo: nil,
			                                     repeats: true)
		}
	}

	func myTimerFunc() {
		print("requestLocation")
		manager.requestLocation()
	}

}

extension AppDelegate: LoginButtonDelegate {
	/**
	Called when the button was used to logout.

	- parameter loginButton: Button that was used to logout.
	*/
	public func loginButtonDidLogOut(_ loginButton: LoginButton) {

	}

	/**
	Called when the button was used to login and the process finished.

	- parameter loginButton: Button that was used to login.
	- parameter result:      The result of the login.
	*/
	public func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
		print(result)
	}
}
