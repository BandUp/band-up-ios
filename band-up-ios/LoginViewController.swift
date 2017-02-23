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
	// MARK: IBOutlets
	@IBOutlet weak var btnLogin: UIButton!
	@IBOutlet weak var txtEmail: UITextField!
	@IBOutlet weak var txtPassword: UITextField!
	@IBOutlet weak var topStackConstraint: NSLayoutConstraint!
	@IBOutlet weak var btnLoginFacebook: UIView!
	@IBOutlet weak var btnLoginSoundCloud: UIView!
	@IBOutlet weak var btnLoginGoogle: UIView!
	
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
		
		btnLogin.layer.cornerRadius = 15
		btnLoginFacebook.layer.cornerRadius = 2
		btnLoginSoundCloud.layer.cornerRadius = 2
		btnLoginGoogle.layer.cornerRadius = 2
		
		let color = UIColor (colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
		
		let attributesDictionary = [NSForegroundColorAttributeName: color]

		txtEmail.attributedPlaceholder = NSAttributedString(string:"Email", attributes: attributesDictionary)
		txtPassword.attributedPlaceholder = NSAttributedString(string: "Password", attributes: attributesDictionary)
		txtPassword.delegate = self
	}
	


	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	/**
	Displays the setup view where instruments and genres are selected with the SetupViewController.
	
	- returns: No return value
	*/
	func displaySetupView() {
		let myVC = self.storyboard?.instantiateViewController(withIdentifier: "SetupViewController") as! SetupViewController
		
		myVC.setupViewObject = Constants.completeSetup
		self.navigationController?.pushViewController(myVC, animated: true)
	}
	
	/**
	Displays the main screen where the user list will be shown first.
	
	- returns: No return value
	*/
	func displayMainScreenView() {
		let storyboard = UIStoryboard(name: "DrawerView", bundle: Bundle.main)
		let mainViewController = storyboard.instantiateViewController(withIdentifier: "DrawerController") as! KYDrawerController
		self.present(mainViewController, animated: true, completion: nil)
	}
	
	// MARK: IBActions
	@IBAction func onClickLogin(_ sender: Any) {
		login()
	}
	
	func login() {
		// Display the network activity indicator in the status bar.
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		// Disable the button while making the request
		// so that no more than one request can be made
		btnLogin.isEnabled = false
		
		// Make the actual request using the Siesta Resource.
		BandUpAPI.sharedInstance.login.request(.post, json: ["username":txtEmail.text, "password":txtPassword.text])
			.onSuccess { (data) in
				// Hide the network activity indicator in the status bar.
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				self.btnLogin.isEnabled = true
				
				let hasFinishedSetup = data.jsonDict["hasFinishedSetup"] as? Bool
				
				// Check if the boolean actually was in the response.
				if hasFinishedSetup != nil {
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
				self.btnLogin.isEnabled = true
				if error.httpStatusCode == 401 {
					print("Wrong email or password")
				} else {
					print(error.httpStatusCode ?? 0)
				}
		}
	}

}

extension LoginViewController: UITextFieldDelegate {

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == txtPassword {
			textField.resignFirstResponder()
			login()
			return false
		}
		return true
	}

}
