//
//  UserListItemView.swift
//  band-up-ios
//
//  Created by Bergþór on 2.1.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit

class UserListItemViewCell: UICollectionViewCell {
	@IBOutlet weak var lblUsername: UILabel!
	@IBOutlet var imgUserImage: RemoteImageView!
	
	@IBOutlet weak var lblAge: UILabel!
	@IBOutlet weak var lblFavInstrument: UILabel!
	@IBOutlet weak var lblDistance: UILabel!
	@IBOutlet weak var lblGenre: UILabel!
	@IBOutlet weak var lblPercentage: UILabel!
	@IBOutlet weak var btnDetails: UIBigButton!
	@IBOutlet weak var btnLike: UIBigButton!
	@IBOutlet weak var actIndicator: UIActivityIndicatorView!
	
	var user = User() {
		didSet {

			self.imgUserImage.delegate = self
			self.imgUserImage.placeholderImage = #imageLiteral(resourceName: "ProfilePlaceholder")
			self.imgUserImage.imageURL = URL(string: user.image.url)


			self.lblUsername.text = user.username
			self.lblPercentage.text = String(format:"\(user.percentage)%%")

			let appDelegate = (UIApplication.shared.delegate as! AppDelegate)

			if let userLocation = appDelegate.lastKnownLocation {
				self.lblDistance.text = user.getDistanceString(between: userLocation)
			} else {
				self.lblDistance.text = user.getDistanceString()
			}

			if (user.favouriteInstrument == "") {
				if (user.instruments.count > 0) {
					self.lblFavInstrument.text = user.instruments[0]
				} else {
					self.lblFavInstrument.text = "user_list_no_instrument".localized
				}
			} else {
				self.lblFavInstrument.text = user.favouriteInstrument
			}

			if (user.genres.count > 0) {
				self.lblGenre.text = user.genres[0]
			} else {
				self.lblGenre.text = "user_list_no_genre".localized
			}

			if user.isLiked {
				self.btnLike.setTitle("user_list_liked".localized, for: .normal)
				self.btnLike.isEnabled = false;
			} else {
				self.btnLike.setTitle("user_list_like".localized, for: .normal)
				self.btnLike.isEnabled = true;
			}
			
			self.lblAge.text = user.getAgeString()
		}
	}

	override func prepareForReuse() {
	}
}

extension UserListItemViewCell: RemoteImageViewDelegate {
	func didFinishLoading() {
		self.actIndicator.stopAnimating()
	}

	func imageWillLoad() {
		self.actIndicator.startAnimating()
	}
}
