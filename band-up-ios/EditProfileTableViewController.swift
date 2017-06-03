//
//  EditProfileTableViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 3.2.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import AVFoundation
import Photos
import Soundcloud

class EditProfileTableViewController: UITableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var txtName: UITextField!
	@IBOutlet weak var lblAge: UILabel!
	@IBOutlet weak var lblFavInstrument: UILabel!
	@IBOutlet weak var imgProfileImage: UIImageView!
	@IBOutlet weak var txtAboutMe: UITextView!
	@IBOutlet weak var tagGenres: BMItemBoxList!
	@IBOutlet weak var tagInstruments: BMItemBoxList!
	@IBOutlet weak var tbcInstruments: UITableViewCell!

	// MARK: - Variables
	var oldUser = User()
	var newUser = User()

	var hasUpdatedImage = false
	
	let INSTRUMENTS_ID = 0
	let GENRES_ID = 1

	@IBAction func didClickLoginSoundCloud(_ sender: BMLoginButton) {
		Soundcloud.login(in: self) { (response) in
			if case .failure(let error) = response.response {
				dump(error)
			} else {
				
			}
		}
	}
	// MARK: - UIViewController Overrides
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if let parentController = self.parent as? EditProfileViewController {
			oldUser = parentController.user
		} else {
			print("Couldn't find parent controller.")
		}
		if let oldCopiedUser = oldUser.copy() as? User {
			newUser = oldCopiedUser
		}

		tagInstruments.strings = oldUser.instruments
		tagGenres.strings = oldUser.genres

		if !hasUpdatedImage {
			self.imgProfileImage.image = oldUser.image.image
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		txtName.delegate = self
		txtAboutMe.delegate = self
		let nameString = "register_username".localized
		let nameStr = NSAttributedString(string: nameString, attributes: [NSForegroundColorAttributeName:UIColor.gray])
		
		txtName.attributedPlaceholder = nameStr
		tableView.keyboardDismissMode = .interactive

		txtName.keyboardAppearance = .dark
		txtAboutMe.keyboardAppearance = .dark

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - UITableView Overrides
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		let colorView = UIView()
		colorView.backgroundColor = UIColor.darkGray
		cell.selectedBackgroundView = colorView
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension

	}
	
	override public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return 44
	}

	func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: IndexPath) {
		let cell  = tableView.cellForRow(at: indexPath)
		cell!.contentView.backgroundColor = .red
	}

	func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: IndexPath) {
		let cell  = tableView.cellForRow(at: indexPath)
		cell!.contentView.backgroundColor = .clear
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
			tableView.deselectRow(at: indexPath, animated: true)
		} else if indexPath.section == 2 {
			displayGenreSetup(at: indexPath)
			tableView.deselectRow(at: indexPath, animated: true)
		} else if indexPath.section == 0 && indexPath.row == 1 {
			displayDatePicker(at: indexPath)
		} else if indexPath.section == 0 && indexPath.row == 2 {
			displayInstrumentPicker(at: indexPath)
		}
	}

	// MARK: - Helper Functions
	// MARK: Photo Management
	func openCamera() -> Bool {
		if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
			let imagePicker = UIImagePickerController()
			imagePicker.delegate = self
			imagePicker.sourceType = UIImagePickerControllerSourceType.camera
			imagePicker.allowsEditing = false
			imagePicker.cameraDevice = .front
			self.present(imagePicker, animated: true, completion: nil)
			return true
		} else {
			return false
		}
	}

	func openLibrary() -> Bool {

		if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
			let imagePicker = UIImagePickerController()
			imagePicker.delegate = self
			imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
			imagePicker.allowsEditing = false
			self.present(imagePicker, animated: true, completion: {UIApplication.shared.statusBarStyle = .default})

			return true
		}
		return false
	}

	@available(iOS 10.0, *)
	func displaySettingsLink(title:String, message:String) {
		let alertController = UIAlertController (title: title, message: message, preferredStyle: .alert)

		let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
			guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
				return
			}

			if UIApplication.shared.canOpenURL(settingsUrl) {
				UIApplication.shared.open(settingsUrl, completionHandler: nil)
			}
		}

		let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)

		alertController.addAction(cancelAction)
		alertController.addAction(settingsAction)
		alertController.preferredAction = settingsAction

		present(alertController, animated: true, completion: nil)
	}

	func displaySettingsMessage(title:String, message:String) {
		let alertController = UIAlertController (title: title, message: message, preferredStyle: .alert)

		let settingsAction = UIAlertAction(title: "OK", style: .cancel)
		alertController.addAction(settingsAction)

		present(alertController, animated: true, completion: nil)
	}

	// MARK: Setup
	func prepareSetupObjectInstruments() -> [SetupViewObject] {
		let setupObject = SetupViewObject(setupResource: BandUpAPI.sharedInstance.instruments)
		
		setupObject.doneButtonText = NSLocalizedString("edit_profile_save", comment: "Button on the bottom of the Instrument and Genre selection screen")
		setupObject.titleHint      = NSLocalizedString("setup_instruments_hint", comment: "Button on the bottom of the Instrument and Genre selection screen")
		setupObject.selected = oldUser.instruments
		setupObject.shouldDismiss = true
		setupObject.id = INSTRUMENTS_ID
		
		return [setupObject]
	}
	
	func prepareSetupObjectGenres() -> [SetupViewObject] {
		let setupObject = SetupViewObject(setupResource: BandUpAPI.sharedInstance.genres)
		
		setupObject.doneButtonText = NSLocalizedString("edit_profile_save", comment: "Button on the bottom of the Instrument and Genre selection screen")
		setupObject.titleHint      = NSLocalizedString("setup_genres_hint", comment: "Button on the bottom of the Instrument and Genre selection screen")
		setupObject.selected = oldUser.genres
		setupObject.shouldDismiss = true
		setupObject.id = GENRES_ID
		
		return [setupObject]
	}
	
	func displayInstrumentSetup(at indexPath: IndexPath) {
		let storyboard = UIStoryboard(name: Storyboard.setup, bundle: Bundle.main)

		guard let myVC = storyboard.instantiateViewController(withIdentifier: ControllerID.setup) as? SetupViewController else {
			return
		}
		
		myVC.setupViewObject = prepareSetupObjectInstruments()
		myVC.delegate = self
		
		present(myVC, animated: true, completion: nil)
	}
	
	func displayGenreSetup(at indexPath: IndexPath) {
		let storyboard = UIStoryboard(name: Storyboard.setup, bundle: Bundle.main)
		
		guard let myVC = storyboard.instantiateViewController(withIdentifier: ControllerID.setup) as? SetupViewController else {
			return
		}
		
		myVC.setupViewObject = prepareSetupObjectGenres()
		myVC.delegate = self
		
		present(myVC, animated: true, completion: nil)
	}

	// MARK: Pickers
	func displayDatePicker(at indexPath: IndexPath) {
		let pickerTitle = NSLocalizedString("dateOfBirth", comment: "Title of ActionSheetDatePicker.")
		
		let datePicker = ActionSheetDatePicker(
			title: pickerTitle,
			datePickerMode: UIDatePickerMode.date,
			selectedDate: newUser.dateOfBirth,
			doneBlock: { picker, value, index in
				self.newUser.dateOfBirth = value as? Date
				self.lblAge.text = self.newUser.getBirthString()
				self.tableView.deselectRow(at: indexPath, animated: true)
				return
			}, cancel: { ActionStringCancelBlock in
				self.tableView.deselectRow(at: indexPath, animated: true)
				return
			}, origin: tableView.cellForRow(at: indexPath)?.superview!.superview
		)
		
		datePicker?.maximumDate = Calendar.current.date(byAdding: .year, value: -(Constants.minAge), to: Date())
		datePicker?.minimumDate = Calendar.current.date(byAdding: .year, value: -(Constants.maxAge), to: Date())
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
				if let values = values as? NSArray {
					self.lblFavInstrument.text = String(describing: values[0])
					self.newUser.favouriteInstrument = String(describing: values[0])
				}
				self.tableView.deselectRow(at: indexPath, animated: true)
				return
			}, cancel: { ActionMultipleStringCancelBlock in
				self.tableView.deselectRow(at: indexPath, animated: true)
				return
			}, origin: tableView.cellForRow(at: indexPath)
		)
	}

	// MARK: - IBActions
	@IBAction func didTapEditPicture(_ sender: UIButton) {
		// 1
		let optionMenu = UIAlertController(title: nil, message: "Upload a Photo", preferredStyle: .actionSheet)

		// 2
		let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { (alert: UIAlertAction!) -> Void in
			let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)

			if status == AVAuthorizationStatus.notDetermined {
				AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
					if granted == true {
						if !self.openCamera() {
							// Camera was not opened successfully
							print("Camera not available")
						}
					}
				})
			}

			if status ==  AVAuthorizationStatus.authorized {
				if !self.openCamera() {
					// Camera was not opened successfully
					print("Camera not available")
				}
			} else if status == AVAuthorizationStatus.denied {
				if #available(iOS 10, *) {
					self.displaySettingsLink(title: "Camera Access Denied", message: "Band Up has been denied from accessing the Camera.\nYou can change access rights in Settings.")
				} else {
					self.displaySettingsMessage(title: "Camera Access Denied", message: "Band Up has been denied from accessing the Camera.\nPlease go to settings and change access rights.")
				}
			} else if status ==  AVAuthorizationStatus.restricted {
				if #available(iOS 10, *) {
					self.displaySettingsLink(title: "Camera Access Restricted", message: "You may not have permission to access the Camera.\nAllow access in Settings -> General -> Restrictions")
				} else {
					self.displaySettingsMessage(title: "Camera Access Restricted", message: "You may not have permission to access the Photo Camera.\nAllow access in Settings -> General -> Restrictions")
				}
			}
		})

		let choosePhotoAction = UIAlertAction(title: "Choose Photo",
		                                      style: .default,
		                                      handler: { (alert: UIAlertAction!) -> Void in

			// Get the current authorization state.
			let status = PHPhotoLibrary.authorizationStatus()

			if status == PHAuthorizationStatus.notDetermined {
				// Access has not been determined.
				PHPhotoLibrary.requestAuthorization({ (newStatus) in
					if newStatus == PHAuthorizationStatus.authorized {
						if !self.openLibrary() {
							print("Library not available")
						}
					}

				})
			} else if status == PHAuthorizationStatus.authorized {
				if !self.openLibrary() {
					print("Library not available")
				}
			} else if status == PHAuthorizationStatus.denied {
				// User Rejected
				if #available(iOS 10, *) {
					self.displaySettingsLink(title: "Photo Library Access Denied", message: "Band Up has been denied from accessing the Photo Library.\nYou can change access rights in Settings.")
				} else {
					self.displaySettingsMessage(title: "Photo Library Access Denied", message: "Band Up has been denied from accessing the Photo Library.\nPlease go to settings and change access rights.")
				}
			} else if status == PHAuthorizationStatus.restricted {
				// User Rejected
				if #available(iOS 10, *) {
					self.displaySettingsLink(title: "Photo Library Access Restricted", message: "You may not have permission to access the Photo Library.\nAllow access in Settings -> General -> Restrictions")
				} else {
					self.displaySettingsMessage(title: "Photo Library Access Restricted", message: "You may not have permission to access the Photo Library.\nAllow access in Settings -> General -> Restrictions")
				}
			}
		})
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		// 4
		optionMenu.addAction(takePhotoAction)
		optionMenu.addAction(choosePhotoAction)
		optionMenu.addAction(cancelAction)

		// 5
		self.present(optionMenu, animated: true, completion: nil)
	}
}

// MARK: - Extensions
extension EditProfileTableViewController: SetupViewControllerDelegate {
	func didSave(_ setup: Int, with data: [String]) {
		// Because of a bug on the server, we need to save the selection to
		// both old user and new user.
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

extension EditProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		hasUpdatedImage = true
		if let newImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
			imgProfileImage.image = newImage
			newUser.image.image = newImage

		}
		
		picker.dismiss(animated: true, completion: nil)
		UIApplication.shared.statusBarStyle = .lightContent
	}

	public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
		UIApplication.shared.statusBarStyle = .lightContent
	}
}

extension EditProfileTableViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return false
	}
}
