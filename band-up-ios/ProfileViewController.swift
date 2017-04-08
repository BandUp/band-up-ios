//
//  ProfileViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 18.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

protocol ProfileViewDelegate: class {
	func update(user: User)
}

class ProfileViewController: UIViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var viewActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var imgProfileImage: RemoteImageView!
	@IBOutlet weak var lblUsername: UILabel!
	@IBOutlet weak var lblAge: UILabel!
	@IBOutlet weak var lblFavInstrument: UILabel!
	@IBOutlet weak var lblInstrumentList: UILabel!
	@IBOutlet weak var lblGenreList: UILabel!
	@IBOutlet weak var lblAboutMe: UILabel!
	@IBOutlet weak var lblError: UILabel!

	// MARK: - Variables
	var currentUser : User?
	weak var delegate : ProfileViewDelegate?

	// MARK: - UIViewController Overrides
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(someAction))

		if currentUser == nil {
			self.parent?.navigationItem.rightBarButtonItem?.isEnabled = false

			BandUpAPI.sharedInstance.profile.load().onSuccess({ (response) in
				self.parent?.navigationItem.rightBarButtonItem?.isEnabled = true
				self.viewActivityIndicator.stopAnimating()
				self.currentUser = User(response.jsonDict as NSDictionary)
				self.populateUser()
				self.scrollView.isHidden = false
				self.lblError.isHidden = true
			}).onFailure({ (error) in
				self.parent?.navigationItem.rightBarButtonItem?.isEnabled = true
				self.viewActivityIndicator.stopAnimating()
				self.scrollView.isHidden = true
				self.lblError.text = "profile_fetch_error".localized
				self.lblError.isHidden = false
			})
		}

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - Helper Functions
	func populateUser() {
		guard let currentUser = currentUser else {
			return
		}

		self.imgProfileImage.delegate = self
		self.imgProfileImage.placeholderImage = #imageLiteral(resourceName: "ProfilePlaceholder")
		self.imgProfileImage.imageURL = URL(string: currentUser.image.url)

		lblUsername.text = currentUser.username
		lblAge.text = currentUser.getAgeString()
		lblFavInstrument.text = currentUser.favouriteInstrument
		if currentUser.aboutme != "" {
			lblAboutMe.text = currentUser.aboutme
		} else {
			lblAboutMe.text = "about_me".localized
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

	public func someAction() {
		guard let currentUser = currentUser else { return }
		if let profileImage = imgProfileImage.image {
			currentUser.image.image = profileImage
		}
		let storyboard = UIStoryboard(name: Storyboard.profile, bundle: Bundle.main)

		if let viewController =  storyboard.instantiateViewController(withIdentifier: ControllerID.editProfile) as? EditProfileViewController {
			viewController.user = currentUser
			viewController.delegate = self
			self.present(viewController, animated: true, completion: nil)
		}

	}

	func shouldShrink(image: UIImage) -> Bool {
		return image.size.height > CGFloat(2048) ||
			   image.size.width > CGFloat(2048)
	}
}
// MARK: - Extensions
extension ProfileViewController: EditProfileViewControllerDelegate {
	func userUpdated(_ newUser: User, hasNewImage:Bool) {
		if let delegate = self.delegate {
			delegate.update(user: newUser)
		}
		
		if hasNewImage {
			let parameters = [
				"file_name": "swift_file.jpeg"
			]

			let progressHUD = MBProgressHUD()
			self.view.addSubview(progressHUD)
			progressHUD.center = self.view.center
			progressHUD.animationType = .zoom
			progressHUD.mode = .determinateHorizontalBar
			progressHUD.label.text = "profile_upload_title".localized
			progressHUD.detailsLabel.text = "profile_upload_message".localized
			progressHUD.show(animated: true)
			let uploadUrl = BandUpAPI.sharedInstance.profilePicture.url.absoluteString

			if let headers = UserDefaults.standard.dictionary(forKey: DefaultsKeys.headers) as? [String:String] {
				Alamofire.upload(multipartFormData: { (multipartFormData) in
					multipartFormData.append(UIImageJPEGRepresentation(self.currentUser!.image.image, 0.7)!, withName: "photo_path", fileName: "swift_file.jpeg", mimeType: "image/jpeg")
					for (key, value) in parameters {
						multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
					}
				}, to: uploadUrl, headers: headers) { (result) in
					switch result {
					case .success(let upload, _, _):

						upload.uploadProgress(closure: { (progress) in
							progressHUD.progressObject = progress
							if progress.fractionCompleted == 1 {
								progressHUD.mode = .indeterminate
							}
						})

						upload.responseJSON { response in
							print("ERROR: \(String(describing: response.error))")
							if response.error == nil {
								if response.response?.statusCode == 201 {
									self.imgProfileImage.image = newUser.image.image
									self.currentUser?.image.image = newUser.image.image
									if let result = response.result.value {
										if let JSON = result as? NSDictionary {
											if let jsonUrl = JSON["url"] as? String {
												self.currentUser?.image.url = jsonUrl
												if let delegate = self.delegate {
													delegate.update(user: newUser)
												}
											}
										}
									}
								}

							}
							progressHUD.hide(animated: true)

						}
					case .failure(_):
						progressHUD.hide(animated: true)
					}
				}
			}
		}
		self.currentUser = newUser

		populateUser()
	}
}

// MARK: RemoteImageViewDelegate Implementation
extension ProfileViewController: RemoteImageViewDelegate {
	func didFinishLoading() {
		self.imageActivityIndicator.stopAnimating()
	}

	func imageWillLoad() {
		self.imageActivityIndicator.startAnimating()
	}
}
