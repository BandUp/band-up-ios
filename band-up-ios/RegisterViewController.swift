//
//  RegisterViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 18.11.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit
import Siesta

class RegisterViewController: UIViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var scrollView: UIScrollView!
	
	// MARK: Views
	@IBOutlet weak var emailView:       UIView!
	@IBOutlet weak var nameView:        UIView!
	@IBOutlet weak var password1View:   UIView!
	@IBOutlet weak var password2View:   UIView!
	@IBOutlet weak var dateOfBirthView: UIView!
	
	// MARK: Labels
	@IBOutlet weak var lblEmail:       UILabel!
	@IBOutlet weak var lblName:        UILabel!
	@IBOutlet weak var lblPassword1:   UILabel!
	@IBOutlet weak var lblPassword2:   UILabel!
	@IBOutlet weak var lblDateOfBirth: UILabel!
	
	// MARK: Text Fields
	@IBOutlet weak var txtEmail:       UITextField!
	@IBOutlet weak var txtName:        UITextField!
	@IBOutlet weak var txtPassword1:   UITextField!
	@IBOutlet weak var txtPassword2:   UITextField!
	@IBOutlet weak var txtDateOfBirth: UITextField!
	
	// MARK: Error Labels
	@IBOutlet weak var lblEmailError:       UILabel!
	@IBOutlet weak var lblNameError:        UILabel!
	@IBOutlet weak var lblPassword1Error:   UILabel!
	@IBOutlet weak var lblPassword2Error:   UILabel!
	@IBOutlet weak var lblDateOfBirthError: UILabel!
	
	// MARK: Buttons
	@IBOutlet weak var btnRegister: UIButton!
	
	// MARK: - IBActions
	// MARK: Text Field Changed
	@IBAction func emailChanged(_ sender: UITextField) {
		lblEmail.isHidden = sender.text == ""
		lblEmailError.isHidden = true
	}

	@IBAction func nameChanged(_ sender: UITextField) {
		lblName.isHidden = sender.text == ""
		lblNameError.isHidden = true
	}

	@IBAction func password1Changed(_ sender: UITextField) {
		lblPassword1.isHidden = sender.text == ""
		lblPassword1Error.isHidden = true
	}

	@IBAction func password2Changed(_ sender: UITextField) {
		lblPassword2.isHidden = sender.text == ""
		lblPassword2Error.isHidden = true
	}
	
	// MARK: Editing Ended
	@IBAction func emailEditEnded(_ sender: UITextField) {
		if sender.text == "" {
			lblEmailError.text = "You must fill in your email address"
			lblEmailError.isHidden = false
			return
		}
		
		if validateEmail(candidate: sender.text!) {
			lblEmailError.isHidden = true
		} else {
			lblEmailError.text = "This email address is not in the correct format"
			lblEmailError.isHidden = false
		}
	}

	@IBAction func nameEditEnded(_ sender: UITextField) {
		if sender.text == "" {
			lblNameError.text = "You must fill in your name"
			lblNameError.isHidden = false
		}
	}

	@IBAction func password1EditEnded(_ sender: UITextField) {
		if sender.text == "" {
			lblPassword1Error.text = "You must fill in a password"
			lblPassword1Error.isHidden = false
		} else if (sender.text?.characters.count)! < 6 {
			lblPassword1Error.text = "Your password must be at least 6 characters long"
			lblPassword1Error.isHidden = false
		}
	}

	@IBAction func password2EditEnded(_ sender: UITextField) {
		if sender.text == "" {
			lblPassword2Error.text = "You must fill in your password again"
			lblPassword2Error.isHidden = false
			return
		}
		
		if txtPassword1.text != txtPassword2.text {
			lblPassword2Error.text = "Passwords do not match"
			lblPassword2Error.isHidden = false
		} else {
			lblPassword2Error.isHidden = true
		}
	}
		
	@IBAction func didTapRegister(_ sender: UIButton) {
		if txtEmail.text == "" {
			lblEmailError.text = "You must fill in your email address"
			lblEmailError.isHidden = false
			txtEmail.becomeFirstResponder()
		} else if txtName.text == "" {
			lblNameError.text = "You must fill in your name"
			lblNameError.isHidden = false
			txtName.becomeFirstResponder()
		} else if txtPassword1.text == "" {
			lblPassword1Error.text = "You must fill in a password"
			lblPassword1Error.isHidden = false
			txtPassword1.becomeFirstResponder()
		} else if txtPassword2.text == "" {
			lblPassword2Error.text = "You must fill in your password again"
			lblPassword2Error.isHidden = false
			txtPassword2.becomeFirstResponder()
		} else if txtPassword1.text == "" && txtPassword2.text == "" {
			lblPassword2Error.text = "Please fill in your password again"
			lblPassword2Error.isHidden = false
			txtPassword2.becomeFirstResponder()
		} else if txtPassword1.text != txtPassword2.text {
			lblPassword1Error.text = "Passwords don't match!"
			lblPassword1Error.isHidden = false
			txtPassword1.becomeFirstResponder()
		} else if txtDateOfBirth.text == "" {
			lblDateOfBirthError.text = "You must fill in your date of birth"
			lblDateOfBirthError.isHidden = false
			txtDateOfBirth.becomeFirstResponder()
		} else if !formIsClean() {
			print("Please fix the remaining errors")
		} else {
			self.btnRegister.isEnabled = false
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

			guard let datePicker = self.txtDateOfBirth.inputView as? UIDatePicker else {
				return
			}

			let dateString:String? = dateFormatter.string(from: datePicker.date)
			// Make the actual request using the Siesta Resource.
			BandUpAPI.sharedInstance.register.request(.post, json: [
				"username":    txtName.text,
				"password":    txtPassword1.text,
				"email":       txtEmail.text,
				"dateOfBirth": dateString
				]
				).onSuccess { (data) in
					_ = self.navigationController?.popViewController(animated: true)
					
					self.btnRegister.isEnabled = true
				}.onFailure { (error) in
					self.btnRegister.isEnabled = true
			}
		}
	}
	
	// MARK: - Overridden Functions
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
		super.viewWillAppear(animated)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		let datePicker = UIDatePicker()
		datePicker.datePickerMode = .date
		self.txtDateOfBirth.inputView = datePicker
		
		datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -(Constants.minAge), to: Date())
		datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -(Constants.maxAge), to: Date())
		datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: datePicker.minimumDate!)
		
		datePicker.addTarget(self, action: #selector(dateChanged), for: UIControlEvents.valueChanged)
		
		let color = UIColor (colorLiteralRed: 1.0, green: 211/255.0, blue: 2/255.0, alpha: 0.5)
		
		let attributesDictionary = [NSForegroundColorAttributeName: color]
		
		txtEmail.attributedPlaceholder = NSAttributedString(string:"Email", attributes: attributesDictionary)
		txtName.attributedPlaceholder = NSAttributedString(string:"Name", attributes: attributesDictionary)
		txtPassword1.attributedPlaceholder = NSAttributedString(string:"Password", attributes: attributesDictionary)
		txtPassword2.attributedPlaceholder = NSAttributedString(string:"Confirm Password", attributes: attributesDictionary)
		txtDateOfBirth.attributedPlaceholder = NSAttributedString(string:"Date of Birth", attributes: attributesDictionary)
				
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - Helper Functions
	func formIsClean() -> Bool {
		return  lblEmailError.isHidden &&
			lblNameError.isHidden &&
			lblPassword1Error.isHidden &&
			lblPassword2Error.isHidden &&
			lblDateOfBirthError.isHidden
	}
	
	func validateEmail(candidate: String) -> Bool {
		let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
		return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
	}
	
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
	
	func dateChanged(_ datePicker: UIDatePicker) {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .long
		let formattedDate = dateFormatter.string(from: datePicker.date)
		
		let age = getAge(datePicker.date)
		self.txtDateOfBirth.text = String(format:"\(formattedDate) (\(age))")
		lblDateOfBirth.isHidden = txtDateOfBirth.text == ""
		lblDateOfBirthError.isHidden = true
	}
	
	func getAge(_ dateOfBirth: Date) -> Int {
		let calendar = Calendar.current
		let now = Date()
		
		let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: now)
		return ageComponents.year!
	}

}
