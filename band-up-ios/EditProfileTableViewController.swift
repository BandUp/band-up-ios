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
	var user = User()
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		user = (self.parent as! EditProfileViewController).user
		tagInstruments.strings = user.instruments
		tagGenres.strings = user.genres
		
	}
	func selectInstrumentCell(_ sender: UIButton) {
		print("SELECTED INSTRUMENTS")
		tableView.selectRow(at: IndexPath(row: 1, section:0), animated: true, scrollPosition: UITableViewScrollPosition(rawValue: 0)!)
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		let selectInstruments = UIGestureRecognizer(target: self, action: #selector(self.selectInstrumentCell(_:)))
		
		tagInstruments.addGestureRecognizer(selectInstruments)
		txtName.delegate = self
		txtAboutMe.delegate = self
		let nameStr = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName:UIColor.gray])
		
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
			return tagInstruments.intrinsicContentSize.height+16
		} else if indexPath.section == 2 {
			return tagGenres.intrinsicContentSize.height+16
		} else if indexPath.section == 3 {
			return 150
		}
		return 44
	}
	
	override public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 1 {
			return tagInstruments.intrinsicContentSize.height+16
		} else if indexPath.section == 2 {
			return tagGenres.intrinsicContentSize.height+16
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
			let storyboard = UIStoryboard(name: "Setup", bundle: Bundle.main)
			
			let myVC = storyboard.instantiateViewController(withIdentifier: "SetupViewController") as! SetupViewController
			
			myVC.setupViewObject = prepareSetupObjectInstruments()
			present(myVC, animated: true, completion: nil)
			tagInstruments.layoutSubviews()
		} else if indexPath.section == 2 {
			let storyboard = UIStoryboard(name: "Setup", bundle: Bundle.main)
			
			let myVC = storyboard.instantiateViewController(withIdentifier: "SetupViewController") as! SetupViewController
			
			myVC.setupViewObject = prepareSetupObjectGenres()
			present(myVC, animated: true, completion: nil)
		} else if indexPath.section == 0 && indexPath.row == 1 {
			let datePicker = ActionSheetDatePicker(title: "Date of Birth", datePickerMode: UIDatePickerMode.date, selectedDate: (parent as! EditProfileViewController).user.dateOfBirth, doneBlock: {
				picker, value, index in
				(self.parent as! EditProfileViewController).user.dateOfBirth = value as! Date
				self.lblAge.text = (self.parent as! EditProfileViewController).user.getAgeString()
				tableView.deselectRow(at: indexPath, animated: true)
				return
			}, cancel: { ActionStringCancelBlock in
				tableView.deselectRow(at: indexPath, animated: true)
				return
			}, origin: tableView.cellForRow(at: indexPath)?.superview!.superview)
			datePicker?.maximumDate = Calendar.current.date(byAdding: .year, value: -(Constants.MIN_AGE), to: Date())
			datePicker?.minimumDate = Calendar.current.date(byAdding: .year, value: -(Constants.MAX_AGE), to: Date())
			datePicker?.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: (datePicker?.minimumDate!)!)
			datePicker?.show()
		} else if indexPath.section == 0 && indexPath.row == 2 {
			ActionSheetMultipleStringPicker.show(withTitle: "Select Instrument", rows: [
				(parent as! EditProfileViewController).user.instruments
				], initialSelection: [0], doneBlock: {
					picker, indexes, values in
					self.lblFavInstrument.text = String(describing: (values as! NSArray)[0])
					tableView.deselectRow(at: indexPath, animated: true)
					return
			}, cancel: { ActionMultipleStringCancelBlock in
				tableView.deselectRow(at: indexPath, animated: true)
				return }, origin: tableView.cellForRow(at: indexPath))
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
