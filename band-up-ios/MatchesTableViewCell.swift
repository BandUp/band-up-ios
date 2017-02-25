//
//  MatchesTableViewCell.swift
//  band-up-ios
//
//  Created by Bergþór on 25.2.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit

class MatchesTableViewCell: UITableViewCell {

	@IBOutlet weak var imgProfile: RemoteImageView!
	@IBOutlet weak var lblUsername: UILabel!

	var user = User() {
		didSet {
			imgProfile.imageURL = URL(string: user.image.url)
			imgProfile.placeholderImage = #imageLiteral(resourceName: "ProfilePlaceholder")
			lblUsername.text = user.username
		}
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		let colorView = UIView()
		colorView.backgroundColor = UIColor.darkGray
		self.selectedBackgroundView = colorView

	}

	override func prepareForReuse() {
		imgProfile.image = nil
		lblUsername.text = ""
	}
}
