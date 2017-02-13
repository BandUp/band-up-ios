//
//  EditProfileTableViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 3.2.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0


class EditProfileTableViewController: UITableViewController {
	@IBOutlet weak var txtName: UITextField!
	@IBOutlet weak var lblAge: UILabel!
	@IBOutlet weak var lblFavInstrument: UILabel!
	@IBOutlet weak var txtAboutMe: UITextView!
	
	@IBOutlet weak var tagGenres: BMItemBoxList!
	@IBOutlet weak var tagInstruments: BMItemBoxList!
	
	@IBOutlet weak var tbcInstruments: UITableViewCell!
	var oldUser = User()
	var newUser = User()
	
	let INSTRUMENTS_ID = 0
	let GENRES_ID = 1
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		oldUser = (self.parent as! EditProfileViewController).user
		newUser = oldUser
		tagInstruments.strings = oldUser.instruments
		tagGenres.strings = oldUser.genres
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		txtName.delegate = self
		txtAboutMe.delegate = self
		let nameString = NSLocalizedString("register_username", comment: "Placeholder for the Name Text Field")
		let nameStr = NSAttributedString(string: nameString, attributes: [NSForegroundColorAttributeName:UIColor.gray])
		
		txtName.attributedPlaceholder = nameStr
		tableView.keyboardDismissMode = .interactive
		tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: UITableViewRowAnimation.none)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 1 {
			return tagInstruments.intrinsicContentSize.height + 16
		} else if indexPath.section == 2 {
			return tagGenres.intrinsicContentSize.height + 16
		} else if indexPath.section == 3 {
			return 150
		}
		return 44
	}
	
	override public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 1 {
			return tagInstruments.intrinsicContentSize.height + 16
		} else if indexPath.section == 2 {
			return tagGenres.intrinsicContentSize.height + 16
		} else if indexPath.section == 3 {
			return 150
		}
		return 44
	}
	
	override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		if indexPath.section == 0 && indexPath.row == 1 {
			return true
		} else if indexPath.section == 0 && indexPath.row == 2 {
			return true
		} else if indexPath.section == 1 {
			return true
		} else if indexPath.section == 2 {
			return true
		}
		
		return false
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
	
		if indexPath.section == 1 {
			displayInstrumentSetup(at: indexPath)
		} else if indexPath.section == 2 {
			displayGenreSetup(at: indexPath)
		} else if indexPath.section == 0 && indexPath.row == 1 {
			displayDatePicker(at: indexPath)
		} else if indexPath.section == 0 && indexPath.row == 2 {
			displayInstrumentPicker(at: indexPath)
		}
	}
	
	func prepareSetupObjectInstruments() -> [SetupViewObject] {
		let setupObject = SetupViewObject(setupResource: BandUpAPI.sharedInstance.instruments)
		
		setupObject.doneButtonText = NSLocalizedString("edit_profile_save", comment: "Button on the bottom of the Instrument and Genre selection screen")
		setupObject.titleHint      = NSLocalizedString("setup_instruments_hint", comment: "Button on the bottom of the Instrument and Genre selection screen")
		setupObject.selected = (self.parent as! EditProfileViewController).user.instruments
		setupObject.shouldDismiss = true
		setupObject.id = INSTRUMENTS_ID
		
		return [setupObject]
	}
	
	func prepareSetupObjectGenres() -> [SetupViewObject] {
		let setupObject = SetupViewObject(setupResource: BandUpAPI.sharedInstance.genres)
		
		setupObject.doneButtonText = NSLocalizedString("edit_profile_save", comment: "Button on the bottom of the Instrument and Genre selection screen")
		setupObject.titleHint      = NSLocalizedString("setup_genres_hint", comment: "Button on the bottom of the Instrument and Genre selection screen")
		setupObject.selected = (self.parent as! EditProfileViewController).user.genres
		setupObject.shouldDismiss = true
		setupObject.id = GENRES_ID
		
		return [setupObject]
	}
	
	func displayInstrumentSetup(at indexPath: IndexPath) {
		let storyboard = UIStoryboard(name: "Setup", bundle: Bundle.main)
		
		let myVC = storyboard.instantiateViewController(withIdentifier: "SetupViewController") as! SetupViewController
		
		myVC.setupViewObject = prepareSetupObjectInstruments()
		myVC.delegate = self
		
		present(myVC, animated: true, completion: nil)
	}
	
	func displayGenreSetup(at indexPath: IndexPath) {
		let storyboard = UIStoryboard(name: "Setup", bundle: Bundle.main)
		
		let myVC = storyboard.instantiateViewController(withIdentifier: "SetupViewController") as! SetupViewController
		
		myVC.setupViewObject = prepareSetupObjectGenres()
		myVC.delegate = self
		
		present(myVC, animated: true, completion: nil)
	}
	
	func displayDatePicker(at indexPath: IndexPath) {
		let pickerTitle = NSLocalizedString("dateOfBirth", comment: "Title of ActionSheetDatePicker.")
		
		let datePicker = ActionSheetDatePicker(
			title: pickerTitle,
			datePickerMode: UIDatePickerMode.date,
			selectedDate: newUser.dateOfBirth,
			doneBlock: { picker, value, index in
				self.newUser.dateOfBirth = value as! Date
				self.lblAge.text = self.newUser.getAgeString()
				return
			}, cancel: { ActionStringCancelBlock in
				return
			}, origin: tableView.cellForRow(at: indexPath)?.superview!.superview
		)
		
		datePicker?.maximumDate = Calendar.current.date(byAdding: .year, value: -(Constants.MIN_AGE), to: Date())
		datePicker?.minimumDate = Calendar.current.date(byAdding: .year, value: -(Constants.MAX_AGE), to: Date())
		datePicker?.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: (datePicker?.minimumDate!)!)
		datePicker?.show()
	}
	
	func displayInstrumentPicker(at indexPath: IndexPath) {
		let pickerTitle = NSLocalizedString("edit_profile_fav_instrument", comment: "Title of ActionSheetStringPicker.")
		let initSelection = newUser.instruments.index(of: newUser.favouriteInstrument) ?? 0
		
		ActionSheetMultipleStringPicker.show(
			withTitle: pickerTitle,
			rows: [newUser.instruments],
			initialSelection: [initSelection],
			doneBlock: { picker, indexes, values in
				self.lblFavInstrument.text = String(describing: (values as! NSArray)[0])
				self.newUser.favouriteInstrument = String(describing: (values as! NSArray)[0])
				return
			}, cancel: { ActionMultipleStringCancelBlock in
				self.tableView.deselectRow(at: indexPath, animated: true)
				return
			}, origin: tableView.cellForRow(at: indexPath)
		)
	}
}

extension EditProfileTableViewController: SetupViewControllerDelegate {
	func didSave(_ setup: Int, with data: [String]) {
		if setup == INSTRUMENTS_ID {
			tableView.beginUpdates()
			tagInstruments.update(strings: data)
			oldUser.instruments = data
			newUser.instruments = data
			tableView.endUpdates()
		} else if setup == GENRES_ID {
			tableView.beginUpdates()
			tagGenres.update(strings: data)
			oldUser.genres = data
			newUser.genres = data
			tableView.endUpdates()
		}
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
			textView.text = NSLocalizedString("edit_profile_influences", comment: "About Me Placeholder")
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
