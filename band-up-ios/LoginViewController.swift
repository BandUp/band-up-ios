//
//  ViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 18.11.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit
import KYDrawerController
import FacebookLogin
import MBProgressHUD
import Soundcloud

class LoginViewController: UIViewController {
	// MARK: IBOutlets
	@IBOutlet weak var btnLogin: UIButton!
	@IBOutlet weak var txtEmail: UITextField!
	@IBOutlet weak var txtPassword: UITextField!
	@IBOutlet weak var scrollView: UIScrollView!

	// MARK: Lazy Variables
	lazy var loginHUD: MBProgressHUD = {
		let hud = MBProgressHUD()
		hud.center = self.view.center
		self.view.addSubview(hud)

		hud.animationType = .zoom
		hud.mode = .indeterminate
		hud.label.text = "login_progress_title".localized
		hud.detailsLabel.text = "login_progress_description".localized
		hud.label.font = UIFont(name: "CaviarDreams-Bold", size: 16)
		hud.detailsLabel.font = UIFont(name: "CaviarDreams", size: 13)

		hud.backgroundView.color = UIColor(white: 0, alpha: 0.7)

		return hud
	}()

	lazy var inputHUD: MBProgressHUD = {
		let hud = MBProgressHUD()
		hud.center = self.view.center
		self.view.addSubview(hud)
		hud.label.font = UIFont(name: "CaviarDreams-Bold", size: 16)
		hud.mode = .text
		hud.animationType = .zoom
		hud.label.numberOfLines = 0
		hud.minShowTime = 5
		hud.hide(animated: true)
		hud.offset.y = -280
		hud.isUserInteractionEnabled = false

		return hud
	}()

	// MARK: UIViewController Overrides
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(true, animated: animated)
		super.viewWillAppear(animated)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		GIDSignIn.sharedInstance().delegate = self
		GIDSignIn.sharedInstance().uiDelegate = self
		btnLogin.layer.cornerRadius = 15

		let color = UIColor (colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)

		let attributesDictionary = [NSForegroundColorAttributeName: color]

		txtEmail.attributedPlaceholder = NSAttributedString(string:"login_username".localized, attributes: attributesDictionary)
		txtPassword.attributedPlaceholder = NSAttributedString(string: "login_password".localized, attributes: attributesDictionary)
		txtPassword.delegate = self

		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: IBActions

	@IBAction func didTapLoginLocal(_ sender: UIButton) {
		if txtEmail.text?.characters.count == 0 {
			inputHUD.label.text = "login_username_validation".localized
			inputHUD.show(animated: true)
			inputHUD.hide(animated: true)
			return
		}
		if txtPassword.text?.characters.count == 0 {
			inputHUD.label.text = "login_password_validation".localized
			inputHUD.show(animated: true)
			inputHUD.hide(animated: true)
			return
		}
		txtEmail.resignFirstResponder()
		txtPassword.resignFirstResponder()
		login()
	}

	@IBAction func didTapLoginFacebook(_ sender: BMLoginButton) {
		let loginManager = LoginManager()

		loginManager.logIn([ .publicProfile, .email ], viewController: self) { loginResult in
			switch loginResult {
			case .failed(let error):
				print(error)
			case .cancelled:
				print("User cancelled login.")
			case .success(_, _, let accessToken):
				self.loginHUD.show(animated: true)
				BandUpAPI.sharedInstance.loginFacebook.request(.post, json: ["access_token" : accessToken.authenticationToken]).onSuccess({ (data) in
					let hasFinishedSetup = data.jsonDict["hasFinishedSetup"] as? Bool
					self.openCorrectView(hasFinishedSetup)

				}).onFailure({ (error) in

				}).onCompletion({ (response) in
					self.loginHUD.hide(animated: true)
				})

			}
		}
	}
	@IBAction func didTapLoginSoundCloud(_ sender: BMLoginButton) {
		Soundcloud.login(in: self) { (response) in
			if case .failure(let error) = response.response {
				dump(error)
			} else {

			}
		}
	}

	@IBAction func didTapLoginGoogle(_ sender: Any) {
		GIDSignIn.sharedInstance().signIn()
	}

	// MARK: Helper functions
	func adjustForKeyboard(notification: Notification) {
		let userInfo = notification.userInfo!
		guard let frameEnd = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
		let keyboardScreenEndFrame = frameEnd.cgRectValue
		let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

		if notification.name == Notification.Name.UIKeyboardWillHide {
			scrollView.contentInset = UIEdgeInsets.zero
		} else {
			scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
		}

		scrollView.scrollIndicatorInsets = scrollView.contentInset
	}

	func openCorrectView(_ hasFinishedSetup:Bool?) {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
			print("Cannot find AppDelegate")
			return
		}

		// Check if the boolean actually was in the response.
		if hasFinishedSetup != nil {
			// If it is in the response,
			// unwrap it and check.
			if (hasFinishedSetup ?? false)! {
				appDelegate.displayMainScreenView()
			} else {
				appDelegate.displaySetupView()
			}
		} else {
			appDelegate.displaySetupView()
		}

	}

	func login() {
		// LoginHUD disables the whole view so we don't need to disable buttons.
		loginHUD.show(animated: true)

		// Make the actual request using the Siesta Resource.
		BandUpAPI.sharedInstance.login.request(.post, json: ["username":txtEmail.text, "password":txtPassword.text])
		.onSuccess { (data) in
				let hasFinishedSetup = data.jsonDict["hasFinishedSetup"] as? Bool
				self.openCorrectView(hasFinishedSetup)
		}.onFailure { (error) in
				if error.httpStatusCode == 401 {
					self.inputHUD.label.text = "login_credentials_incorrect".localized
					self.inputHUD.show(animated: true)
					self.inputHUD.hide(animated: true)
				} else {
					self.inputHUD.label.text = error.cause?.localizedDescription
					self.inputHUD.show(animated: true)
					self.inputHUD.hide(animated: true)

				}
		}.onCompletion { (response) in
			self.loginHUD.hide(animated: true)
		}
	}

}

extension LoginViewController: GIDSignInUIDelegate {

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

extension LoginViewController: GIDSignInDelegate {
	public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
		if error == nil {
			// Perform any operations on signed in user here.
			let idToken = user.authentication.idToken // Safe to send to the server
			loginHUD.show(animated: true)
			BandUpAPI.sharedInstance.loginGoogle.request(.post, json: ["access_token":idToken!])
				.onSuccess { (data) in
					// Hide the network activity indicator in the status bar.
					let hasFinishedSetup = data.jsonDict["hasFinishedSetup"] as? Bool
					self.openCorrectView(hasFinishedSetup)
				}.onFailure { (error) in
					// Hide the network activity indicator in the status bar.
					if error.httpStatusCode == 401 {
						print("Wrong email or password")
					} else {
						print(error.httpStatusCode ?? 0)
					}
			}.onCompletion({ (response) in
				self.loginHUD.hide(animated: true)
			})
		} else {
			print("\(error.localizedDescription)")
			loginHUD.hide(animated: true)
		}
	}
}
