//
//  EditProfileTableViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 3.2.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit

class EditProfileTableViewController: UITableViewController {
	@IBOutlet weak var txtName: UITextField!
	@IBOutlet weak var lblAge: UILabel!
	@IBOutlet weak var lblInstruments: UILabel!
	@IBOutlet weak var lblGenres: UILabel!
	@IBOutlet weak var lblFavInstrument: UILabel!
	@IBOutlet weak var txtAboutMe: UITextView!
	override func viewDidLoad() {
		super.viewDidLoad()
		txtName.delegate = self
		txtAboutMe.delegate = self
		let nameStr = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName:UIColor.gray])
		
		txtName.attributedPlaceholder = nameStr
		//txtAboutMe.attributedPlaceholder = aboutMeStr
		tableView.keyboardDismissMode = .onDrag
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print("Section:\(indexPath.section), Row: \(indexPath.row)")
		if indexPath.section == 1 {
			let storyboard = UIStoryboard(name: "Setup", bundle: Bundle.main)

			let myVC = storyboard.instantiateViewController(withIdentifier: "SetupViewController") as! SetupViewController
			
			myVC.setupViewObject = prepareSetupObjectInstruments()
			present(myVC, animated: true, completion: nil)
		} else if indexPath.section == 2 {
			let storyboard = UIStoryboard(name: "Setup", bundle: Bundle.main)
			
			let myVC = storyboard.instantiateViewController(withIdentifier: "SetupViewController") as! SetupViewController
			
			myVC.setupViewObject = prepareSetupObjectGenres()
			present(myVC, animated: true, completion: nil)
		}
	}
	
	func prepareSetupObjectInstruments() -> [SetupViewObject] {
		let setupObject = SetupViewObject(setupResource: bandUpAPI.instruments)
		
		setupObject.doneButtonText = "Done"
		setupObject.titleHint      = "What instruments do you play?"
		setupObject.selected = (self.parent as! EditProfileViewController).user.instruments
		setupObject.shouldDismiss = true
		
		return [setupObject]
	}
	
	func prepareSetupObjectGenres() -> [SetupViewObject] {
		let setupObject = SetupViewObject(setupResource: bandUpAPI.genres)
		
		setupObject.doneButtonText = "Done"
		setupObject.titleHint      = "What is your taste in music?"
		setupObject.selected = (self.parent as! EditProfileViewController).user.genres
		setupObject.shouldDismiss = true
		
		return [setupObject]
	}
	
}

extension EditProfileTableViewController: UITextViewDelegate {
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.textColor == UIColor.lightGray {
			textView.text = nil
			textView.textColor = UIColor.white
		}
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text.isEmpty {
			textView.text = "Tell us about your influences and experience"
			textView.textColor = UIColor.lightGray
		}
	}
}

extension EditProfileTableViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return false
	}
}
