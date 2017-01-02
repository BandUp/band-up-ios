//
//  ProfileViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 18.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
	
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var imgProfileImage: UIImageView!
	@IBOutlet weak var lblUsername: UILabel!
	@IBOutlet weak var lblAge: UILabel!
	@IBOutlet weak var lblFavInstrument: UILabel!
	@IBOutlet weak var lblInstrumentList: UILabel!
	@IBOutlet weak var lblGenreList: UILabel!
	@IBOutlet weak var lblAboutMe: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		activityIndicator.stopAnimating()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
}
