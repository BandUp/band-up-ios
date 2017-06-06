//
//  PasswordResetView.swift
//  band-up-ios
//
//  Created by Bergþór on 3.6.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import Foundation
import MBProgressHUD

class PasswordResetView: UIView {
	// Our custom view from the XIB file
	var view: UIView!
	@IBOutlet weak var txtEmail: UITextField!
	@IBOutlet weak var btnResetPassword: UIButton!

	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	/**
	Loads a view instance from the xib file

	- returns: loaded view
	*/
	func loadViewFromXibFile() -> UIView {
		let bundle = Bundle(for: type(of: self))
		let nib = UINib(nibName: "PasswordResetView", bundle: bundle)

		guard let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView else {
			return UIView()
		}
		return view
	}

	/**
	Initialiser method
	*/
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}

	/**
	Initialiser method
	*/
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupView()

	}
	lazy var inputHUD: MBProgressHUD = {
		var hud = MBProgressHUD()
		guard let onView = self.onView else {
			return hud
		}

		hud.center = onView.center
		onView.addSubview(hud)
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

	@IBAction func didTapResetPassword(_ sender: Any) {
		guard let email = txtEmail.text else {
			return
		}
		if !validateEmail(candidate: email) {
			inputHUD.label.text = "password_reset_email_invalid_message".localized
			self.inputHUD.show(animated: true)
			self.inputHUD.hide(animated: true)
			return
		}
		btnResetPassword.isEnabled = false
		activityIndicator.startAnimating()
		BandUpAPI.sharedInstance.resetPassword.request(.post, json:["email": email]).onSuccess { (response) in
			self.inputHUD.label.text = "reset_email_done".localized
			self.inputHUD.show(animated: true)
			self.inputHUD.hide(animated: true)
			self.txtEmail.text = ""
			self.closeView()
			self.btnResetPassword.isEnabled = true
			self.activityIndicator.stopAnimating()
			}.onFailure { (error) in
				self.inputHUD.label.text = "reset_email_error".localized
				self.inputHUD.show(animated: true)
				self.inputHUD.hide(animated: true)
				self.btnResetPassword.isEnabled = false
				self.activityIndicator.stopAnimating()
		}
	}

	func validateEmail(candidate: String) -> Bool {
		let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
		return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
	}

	/**
	Sets up the view by loading it from the xib file and setting its frame
	*/
	func setupView() {
		view = loadViewFromXibFile()
		view.frame = bounds
		view.translatesAutoresizingMaskIntoConstraints = false
		addSubview(view)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)

		translatesAutoresizingMaskIntoConstraints = false

		//titleLabel.text = NSLocalizedString("Saved_to_garage", comment: "")
		txtEmail.keyboardAppearance = .dark
		/// Adds a shadow to our view
		view.layer.cornerRadius = 10.0
		view.layer.shadowColor = UIColor.black.cgColor
		view.layer.shadowOpacity = 0.4
		view.layer.shadowRadius = 6.0
		view.layer.masksToBounds = true
		view.layer.shadowOffset = CGSize(width: 0.0, height: 8.0)

		btnResetPassword.layer.backgroundColor = UIColor.bandUpYellow.cgColor
		btnResetPassword.layer.cornerRadius = 10
		btnResetPassword.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)
		self.txtEmail.delegate = self

	}

	/**
	Updates constraints for the view. Specifies the height and width for the view
	*/
	override func updateConstraints() {
		super.updateConstraints()

		addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 300.0))

		addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0))
		addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0))
		addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0))
		addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
	}
	@IBAction func closeButtonTapped(_ sender: Any) {
		closeView()
	}
	var const: NSLayoutConstraint?
	var onView:UIView?

	var blurEffectView: UIView?
	func closeView() {
		self.txtEmail.resignFirstResponder()
		UIView.animate(withDuration: 0.3, delay: TimeInterval(0), options: [.curveEaseInOut], animations: {
			self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
			self.alpha = 0
		}, completion: { (bla) in
			self.removeFromSuperview()
		})

		self.txtEmail.resignFirstResponder()
		UIView.animate(withDuration: 0.3, delay: TimeInterval(0.07), options: [.curveEaseInOut], animations: {
			if let blurEffectView = self.blurEffectView {
				blurEffectView.alpha = 0
			}
		}, completion: { (bla) in
			if let blurEffectView = self.blurEffectView {
				blurEffectView.removeFromSuperview()
			}
		})
	}

	func displayView(onView: UIView, withEmail email:String?) {
		self.onView = onView
		let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
		blurEffectView = UIVisualEffectView(effect: blurEffect)
		guard let blurEffectView = blurEffectView else {
			return
		}
		blurEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeView)))
		blurEffectView.frame = onView.bounds
		blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		blurEffectView.alpha = 0
		self.alpha = 0
		onView.addSubview(blurEffectView)
		self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)

		UIView.animate(withDuration: 0.3, delay: TimeInterval(0), options: [.curveEaseInOut], animations: {
			self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
			blurEffectView.alpha = 1
			self.alpha = 1
		})
		onView.addSubview(self)
		const = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: onView, attribute: .centerY, multiplier: 1.0, constant: 0.0)

		onView.addConstraint(const!) // move it a bit upwards
		onView.addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: onView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
		onView.needsUpdateConstraints()
		superview?.layoutIfNeeded()
		txtEmail.becomeFirstResponder()
		onView.bringSubview(toFront: inputHUD)
		if let email = email {
			txtEmail.text = email
		}
	}

	func keyboardNotification(notification: NSNotification) {
		guard let onView = self.onView else {
			return
		}

		if let userInfo = notification.userInfo {

			let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue

			let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
			let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
			let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
			let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
			if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
				self.const?.constant = 0.0
			} else {
				self.const?.constant = -(endFrame?.size.height ?? 0.0)/2
			}
			view.layoutIfNeeded()
			UIView.animate(withDuration: duration,
			               delay: TimeInterval(0),
			               options: animationCurve,
			               animations: {

							onView.layoutIfNeeded()
			},
			               completion: nil)
		}
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}

extension PasswordResetView: UITextFieldDelegate {

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == txtEmail {
			didTapResetPassword(btnResetPassword)
			return false
		}
		return true
	}
}
