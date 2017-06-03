//
//  EditProfileViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 28.1.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit

protocol EditProfileViewControllerDelegate: class {
	func userUpdated(_ newUser: User, hasNewImage: Bool)
}

class EditProfileViewController: UIViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var btnDone: UIBarButtonItem!
	@IBOutlet weak var btnCancel: UIBarButtonItem!
	@IBOutlet weak var containerView: UIView!

	// MARK: - Variables
	var tableViewController: EditProfileTableViewController = EditProfileTableViewController()
	
	var user = User()
	weak var delegate : EditProfileViewControllerDelegate?

	// MARK: - UIViewController Overrides
	override func viewDidLoad() {
		super.viewDidLoad()
		tableViewController.txtName.text = user.username
		tableViewController.lblFavInstrument.text = user.favouriteInstrument
		tableViewController.txtName.textColor = UIColor.lightGray
		
		if user.aboutme == "" {
			tableViewController.txtAboutMe.text = NSLocalizedString("edit_profile_influences", comment: "About Me Placeholder")
			tableViewController.txtAboutMe.textColor = UIColor.lightGray
		} else {
			tableViewController.txtAboutMe.text = user.aboutme
			tableViewController.txtAboutMe.textColor = UIColor.white
		}
		
		tableViewController.lblAge.text = String(user.getBirthString())
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? EditProfileTableViewController, segue.identifier == "EditProfileTableSegue" {
			self.tableViewController = vc
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - IBActions
	@IBAction func didTapDone(_ sender: Any) {
		btnDone.isEnabled = false

		var updatedUser: [String:String] = [:]
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
		var dateString: String = ""

		if let safeDate = tableViewController.newUser.dateOfBirth {
			user.dateOfBirth = safeDate
			dateString = dateFormatter.string(from: safeDate)
		}
		
		updatedUser["username"] = tableViewController.txtName.text
		updatedUser["favoriteinstrument"] = tableViewController.newUser.favouriteInstrument
		updatedUser["aboutme"] = tableViewController.txtAboutMe.text
		updatedUser["dateOfBirth"] = dateString
		
		user.username = tableViewController.txtName.text!
		user.aboutme = tableViewController.txtAboutMe.text
		
		BandUpAPI.sharedInstance.editProfile.request(.post, json: updatedUser).onSuccess { (response) in
			self.tableViewController.txtName.resignFirstResponder()
			self.tableViewController.txtAboutMe.resignFirstResponder()
			if let del = self.delegate {
				del.userUpdated(self.user, hasNewImage: self.tableViewController.hasUpdatedImage)
			}
			self.dismiss(animated: true, completion: nil)
			
		}.onFailure { (error) in
			self.navigationItem.rightBarButtonItem?.isEnabled = true
		}

	}
	
	@IBAction func didTapCancel(_ sender: Any) {
		tableViewController.txtName.resignFirstResponder()
		tableViewController.txtAboutMe.resignFirstResponder()
		if let del = self.delegate {
			del.userUpdated(tableViewController.oldUser, hasNewImage: false)
		}
		self.dismiss(animated: true, completion: nil)
	}

	func updateProfileImage(image:UIImage) {
		tableViewController.updateProfileImage(image: image)
	}
	
}
