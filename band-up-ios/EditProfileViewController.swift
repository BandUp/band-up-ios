//
//  EditProfileViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 28.1.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {
	@IBOutlet weak var btnDone: UIBarButtonItem!
	@IBOutlet weak var btnCancel: UIBarButtonItem!
	@IBOutlet weak var containerView: UIView!
	var tableViewController: EditProfileTableViewController = EditProfileTableViewController()
	
	var user = User()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableViewController.txtName.text = user.username
		tableViewController.lblFavInstrument.text = user.favouriteInstrument
		tableViewController.txtName.textColor = UIColor.lightGray
		
		if (user.aboutme == "") {
			tableViewController.txtAboutMe.text = NSLocalizedString("edit_profile_influences", comment: "About Me Placeholder")
			tableViewController.txtAboutMe.textColor = UIColor.lightGray
		} else {
			tableViewController.txtAboutMe.text = user.aboutme
			tableViewController.txtAboutMe.textColor = UIColor.white
		}
		
		tableViewController.lblAge.text = String(user.getAgeString())

		
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
			//tableViewController.lblInstruments.text = instruString
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
		self.dismiss(animated: true, completion: nil)

	}
	
	@IBAction func didTapCancel(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
}
