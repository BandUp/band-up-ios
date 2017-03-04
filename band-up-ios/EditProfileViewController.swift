//
//  EditProfileViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 28.1.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit

protocol EditProfileViewControllerDelegate: class {
	func userUpdated(_ newUser: User)
}

class EditProfileViewController: UIViewController {
	@IBOutlet weak var btnDone: UIBarButtonItem!
	@IBOutlet weak var btnCancel: UIBarButtonItem!
	@IBOutlet weak var containerView: UIView!
	var tableViewController: EditProfileTableViewController = EditProfileTableViewController()
	
	var user = User()
	weak var delegate : EditProfileViewControllerDelegate?
	
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

		var count = user.instruments.count
		if count > 0 {
			let last = user.instruments[count-1]
			var instruString = ""
			for instrument in user.instruments {
				instruString += instrument
				if instrument != last {
					instruString += ", "
				}
			}
		}

		count = user.genres.count
		if count > 0 {
			let last = user.genres[count-1]
			var genreString = ""
			for genre in user.genres {
				genreString += genre
				if genre != last {
					genreString += ", "
				}
			}
		}
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

	@IBAction func didTapDone(_ sender: Any) {
		print("bla")
		btnDone.isEnabled = false

		var updatedUser: [String:String] = [:]
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
		var dateString: String = ""
		if let safeDate = tableViewController.newUser.dateOfBirth {
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
				del.userUpdated(self.user)
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
			del.userUpdated(tableViewController.oldUser)
		}
		self.dismiss(animated: true, completion: nil)
	}
	
}
