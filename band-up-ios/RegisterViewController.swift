//
//  RegisterViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 18.11.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
	
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnRegister: UIButton!
	@IBOutlet weak var txtDateOfBirth: UITextField!
	@IBOutlet weak var txtPassword1: UITextField!
	@IBOutlet weak var txtPassword2: UITextField!
	@IBOutlet weak var btnPassword1: UITextField!
	@IBOutlet weak var txtName: UITextField!
	
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
		super.viewWillAppear(animated)
	}
	
	@IBAction func didTapRegister(_ sender: UIButton) {
		// Make the actual request using the Siesta Resource.
		self.btnRegister.isEnabled = false
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
		let datePicker = self.txtDateOfBirth.inputView as! UIDatePicker
		let dateString:String? = dateFormatter.string(from: datePicker.date)
		
		bandUpAPI.register.request(.post, json: [
			"username":    txtName.text,
			"password":    txtPassword1.text,
			"email":       txtEmail.text,
			"dateOfBirth": dateString
			]
			).onSuccess { (data) in
				// Hide the network activity indicator in the status bar.
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				self.navigationController?.popViewController(animated: true)
				
				self.btnRegister.isEnabled = true
			}.onFailure { (error) in
				// Hide the network activity indicator in the status bar.
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				self.btnRegister.isEnabled = true;
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		let datePicker = UIDatePicker()
		datePicker.datePickerMode = .date
		self.txtDateOfBirth.inputView = datePicker
		
		
		datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -13, to: Date())
		datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -99, to: Date())
		datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: datePicker.minimumDate!)
		
		datePicker.addTarget(self, action: #selector(dateChanged), for: UIControlEvents.valueChanged)
		
	}
	
	func dateChanged(_ datePicker: UIDatePicker) {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
		let formattedDate = dateFormatter.string(from: datePicker.date)
		
		let age = getAge(datePicker.date)
		self.txtDateOfBirth.text = String(format:"\(formattedDate) (\(age))")
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func getAge(_ dateOfBirth: Date) -> Int {
		let calendar = Calendar.current
		let now = Date()
		
		let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: now)
		return ageComponents.year!
	}
	
	
}
