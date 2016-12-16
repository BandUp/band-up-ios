//
//  ViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 18.11.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
	@IBOutlet weak var btnLogin: UIButton!
	@IBOutlet weak var txtEmail: UITextField!
	@IBOutlet weak var txtPassword: UITextField!
	@IBOutlet weak var topStackConstraint: NSLayoutConstraint!
	@IBOutlet weak var btnLoginFacebook: UIView!
	@IBOutlet weak var btnLoginSoundCloud: UIView!
	@IBOutlet weak var btnLoginGoogle: UIView!
	@IBAction func onClickLogin(_ sender: Any) {
		
		let myVC = storyboard?.instantiateViewController(withIdentifier: "SetupViewController") as! SetupViewController
		myVC.setupViewObject.doneButtonText = "Next"
		myVC.setupViewObject.titleUpperLeft = "Let's get started"
		myVC.setupViewObject.titleUpperRight = "1/2"
		myVC.setupViewObject.titleHint = "What instruments do you play?"
		myVC.setupViewObject.apiURL = "https://band-up-server.herokuapp.com"
		navigationController?.pushViewController(myVC, animated: true)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(true, animated: animated)
		super.viewWillAppear(animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
		super.viewWillDisappear(animated)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		btnLogin.layer.cornerRadius = 5;
		btnLoginFacebook.layer.cornerRadius = 2;
		btnLoginSoundCloud.layer.cornerRadius = 2;
		btnLoginGoogle.layer.cornerRadius = 2;
		
		let color = UIColor (colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.5);
		
		let attributesDictionary = [NSForegroundColorAttributeName: color]
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)

		txtEmail.attributedPlaceholder = NSAttributedString(string:"Email", attributes: attributesDictionary)
		txtPassword.attributedPlaceholder = NSAttributedString(string: "Password", attributes: attributesDictionary)
		
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

