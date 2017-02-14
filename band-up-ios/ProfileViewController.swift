//
//  ProfileViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 18.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

protocol ProfileViewDelegate {
	func update(user: User)
}

class ProfileViewController: UIViewController {


	func openCamera() -> Bool{
		if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
			let imagePicker = UIImagePickerController()
			imagePicker.delegate = self
			imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
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
			imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
			imagePicker.allowsEditing = false
			self.present(imagePicker, animated: true, completion: nil)
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

	@IBAction func didTapImage(_ sender: Any) {
		// 1
		let optionMenu = UIAlertController(title: nil, message: "Upload a Photo", preferredStyle: .actionSheet)

		// 2
		let deleteAction = UIAlertAction(title: "Take Photo", style: .default, handler: {
			(alert: UIAlertAction!) -> Void in
			let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)

			if (status == AVAuthorizationStatus.notDetermined) {
				AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
					if granted == true {
						if !self.openCamera() {
							// Camera was not opened successfully
							print("Camera not available")
						}
					}
				});
			}

			if (status ==  AVAuthorizationStatus.authorized) {
				if !self.openCamera() {
					// Camera was not opened successfully
					print("Camera not available")
				}
			} else if (status == AVAuthorizationStatus.denied) {
				if #available(iOS 10, *) {
					self.displaySettingsLink(title: "Camera Access Denied", message: "Band Up has been denied from accessing the Camera.\nYou can change access rights in Settings.")
				} else {
					self.displaySettingsMessage(title: "Camera Access Denied", message: "Band Up has been denied from accessing the Camera.\nPlease go to settings and change access rights.")
				}
			} else if (status ==  AVAuthorizationStatus.restricted) {
				if #available(iOS 10, *) {
					self.displaySettingsLink(title: "Camera Access Restricted", message: "You may not have permission to access the Camera.\nAllow access in Settings -> General -> Restrictions")
				} else {
					self.displaySettingsMessage(title: "Camera Access Restricted", message: "You may not have permission to access the Photo Camera.\nAllow access in Settings -> General -> Restrictions")
				}
			}
		})

		let saveAction = UIAlertAction(title: "Choose Photo", style: .default, handler: {
			(alert: UIAlertAction!) -> Void in

			// Get the current authorization state.
			let status = PHPhotoLibrary.authorizationStatus()

			if (status == PHAuthorizationStatus.notDetermined) {
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
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
			(alert: UIAlertAction!) -> Void in
		})
		// 4
		optionMenu.addAction(deleteAction)
		optionMenu.addAction(saveAction)
		optionMenu.addAction(cancelAction)

		// 5
		self.present(optionMenu, animated: true, completion: nil)
	}
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var viewActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var imgProfileImage: UIImageView!
	@IBOutlet weak var lblUsername: UILabel!
	@IBOutlet weak var lblAge: UILabel!
	@IBOutlet weak var lblFavInstrument: UILabel!
	@IBOutlet weak var lblInstrumentList: UILabel!
	@IBOutlet weak var lblGenreList: UILabel!
	@IBOutlet weak var lblAboutMe: UILabel!
	@IBOutlet weak var lblError: UILabel!
	
	var currentUser = User()
	var delegate : ProfileViewDelegate?
	override func viewDidLoad() {
		super.viewDidLoad()
		self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(someAction))
		self.parent?.navigationItem.rightBarButtonItem?.isEnabled = false
		BandUpAPI.sharedInstance.profile.load().onSuccess({ (response) in
			self.parent?.navigationItem.rightBarButtonItem?.isEnabled = true
			self.viewActivityIndicator.stopAnimating()
			self.currentUser = User(response.jsonDict as NSDictionary)
			self.populateUser()
			self.scrollView.isHidden = false
		}).onFailure({ (error) in
			print("FAILURE")
			self.viewActivityIndicator.stopAnimating()
			self.scrollView.isHidden = true
			self.lblError.text = "Could not get your profile"
			self.lblError.isHidden = false

		})
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(someAction))
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	// MARK: - Helper Functions
	func populateUser() {
		imgProfileImage.image = nil
		
		if let checkedUrl = URL(string: currentUser.image.url) {
			self.downloadImage(url: checkedUrl, imageView: imgProfileImage, activityIndicator: imageActivityIndicator)
		} else {
			imageActivityIndicator.stopAnimating()
			imgProfileImage.image = #imageLiteral(resourceName: "ProfilePlaceholder")
			
		}
		
		lblUsername.text = currentUser.username
		lblAge.text = "\(currentUser.getAge()) years old"
		lblFavInstrument.text = currentUser.favouriteInstrument
		if (currentUser.aboutme != "") {
			lblAboutMe.text = currentUser.aboutme
		} else {
			lblAboutMe.text = NSLocalizedString("about_me", comment: "About Me string displayed on the profiles")
		}
		
		var instrumentString = ""
		for instrument in currentUser.instruments {
			instrumentString += instrument
			if currentUser.instruments.index(of: instrument) !=
				currentUser.instruments.count-1 {
				instrumentString += "\n"
			}
		}
		lblInstrumentList.numberOfLines = currentUser.instruments.count
		lblInstrumentList.text = instrumentString
		
		var genreString = ""
		for genre in currentUser.genres {
			genreString += genre
			if currentUser.genres.index(of: genre) !=
				currentUser.genres.count-1 {
				genreString += "\n"
			}
		}
		
		lblGenreList.numberOfLines = currentUser.genres.count
		lblGenreList.text = genreString
	}
	
	func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
		URLSession.shared.dataTask(with: url) {
			(data, response, error) in
			completion(data, response, error)
			}.resume()
	}
	
	func downloadImage(url: URL, imageView: UIImageView, activityIndicator: UIActivityIndicatorView) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		activityIndicator.startAnimating()
		getDataFromUrl(url: url) { (data, response, error)  in
			guard let data = data, error == nil else { return }
			DispatchQueue.main.async() { () -> Void in
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				activityIndicator.stopAnimating()
				imageView.image = UIImage(data: data)
			}
		}
	}
	
	public func someAction() {
		let storyboard = UIStoryboard(name: "ProfileView", bundle: Bundle.main)
		
		let viewController =  storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
		viewController.user = currentUser
		viewController.delegate = self
		self.present(viewController, animated: true, completion: nil)
	}
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		print(info)
		imgProfileImage.image = (info["UIImagePickerControllerOriginalImage"] as! UIImage)
		picker.dismiss(animated: true, completion: nil)
	}


	public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}

extension ProfileViewController: EditProfileViewControllerDelegate {
	func userUpdated(_ newUser: User) {
		self.currentUser = newUser
		populateUser()
	}
}
