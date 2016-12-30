//
//  ViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 18.11.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit
import KYDrawerController

class LoginViewController: UIViewController {
	@IBOutlet weak var btnLogin: UIButton!
	@IBOutlet weak var txtEmail: UITextField!
	@IBOutlet weak var txtPassword: UITextField!
	@IBOutlet weak var topStackConstraint: NSLayoutConstraint!
	@IBOutlet weak var btnLoginFacebook: UIView!
	@IBOutlet weak var btnLoginSoundCloud: UIView!
	@IBOutlet weak var btnLoginGoogle: UIView!
	
	@IBAction func onClickLogin(_ sender: Any) {
		// Display the network activity indicator in the status bar.
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		// Disable the button while making the request
		// so that no more than one request can be made
		btnLogin.isEnabled = false;
		
		// Make the actual request using the Siesta Resource.
		bandUpAPI.login.request(.post, json: ["username":txtEmail.text, "password":txtPassword.text])
			.onSuccess { (data) in
				// Hide the network activity indicator in the status bar.
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				self.btnLogin.isEnabled = true;

				let hasFinishedSetup = data.jsonDict["hasFinishedSetup"] as? Bool
				
				// Check if the boolean actually was in the response.
				if (hasFinishedSetup != nil) {
					// If it is in the response,
					// unwrap it and check.
					if (hasFinishedSetup ?? false)! {
						self.displayMainScreenView()
					} else {
						self.displaySetupView()
					}
				} else {
					self.displaySetupView()
				}
				
			}.onFailure { (error) in
				// Hide the network activity indicator in the status bar.
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				self.btnLogin.isEnabled = true;
				if (error.httpStatusCode == 401) {
					print("Wrong email or password")
				} else {
					print(error.httpStatusCode ?? 0)
				}
		}
	}
	
	func displaySetupView() {
		let myVC = self.storyboard?.instantiateViewController(withIdentifier: "SetupViewController") as! SetupViewController
		
		myVC.setupViewObject = prepareSetupObject()
		self.navigationController?.pushViewController(myVC, animated: true)
	}
	
	func displayMainScreenView() {
		let storyboard = UIStoryboard(name: "MainScreen", bundle: nil)
		let mainViewController = storyboard.instantiateViewController(withIdentifier: "DrawerController") as! KYDrawerController
		self.present(mainViewController, animated: true, completion: nil)
	}
	
	func prepareSetupObject() -> SetupViewObject {
		let setupObject = SetupViewObject(setupResource: bandUpAPI.instruments)
		
		setupObject.doneButtonText = "Next"
		setupObject.titleUpperLeft = "Let's get started"
		setupObject.setupViewIndex = 1
		setupObject.setupViewCount = 2
		setupObject.titleHint      = "What instruments do you play?"
		
		return setupObject
	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(true, animated: animated)
		super.viewWillAppear(animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		btnLogin.layer.cornerRadius = 12;
		btnLoginFacebook.layer.cornerRadius = 2;
		btnLoginSoundCloud.layer.cornerRadius = 2;
		btnLoginGoogle.layer.cornerRadius = 2;
		
		let color = UIColor (colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.5);
		
		let attributesDictionary = [NSForegroundColorAttributeName: color]

		txtEmail.attributedPlaceholder = NSAttributedString(string:"Email", attributes: attributesDictionary)
		txtPassword.attributedPlaceholder = NSAttributedString(string: "Password", attributes: attributesDictionary)
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
		
	}
	
	func keyboardNotification(notification: NSNotification) {
		if let userInfo = notification.userInfo {
			let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
			let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
			let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
			let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
			let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
			if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
				self.topStackConstraint?.constant = 75.0
			} else {
				self.topStackConstraint?.constant = 20.0
			}
			UIView.animate(withDuration: duration,
			               delay: TimeInterval(0),
			               options: animationCurve,
			               animations: { self.view.layoutIfNeeded() },
			               completion: nil)
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

