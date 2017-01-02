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
	@IBOutlet weak var imgUserImage: UIImageView!
	
	@IBOutlet weak var lblAge: UILabel!
	@IBOutlet weak var lblFavInstrument: UILabel!
	@IBOutlet weak var lblDistance: UILabel!
	@IBOutlet weak var lblGenre: UILabel!
	@IBOutlet weak var lblPercentage: UILabel!
	@IBOutlet weak var btnDetails: UIBigButton!
	@IBOutlet weak var btnLike: UIBigButton!
	@IBOutlet weak var actIndicator: UIActivityIndicatorView!
	
	var user = User()
}
