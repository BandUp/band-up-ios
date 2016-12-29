//
//  UserItemViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 18.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit
import Siesta

class UserItemViewController: UIViewController {

	@IBOutlet weak var btnLike: UIButton!
	
	@IBOutlet weak var btnDetails: UIButton!
	
	@IBOutlet weak var lblUsername: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		btnLike.layer.cornerRadius = 15;
		btnDetails.layer.cornerRadius = 15;
		

		bandUpAPI.nearby.addObserver(owner: self) {
			[weak self] resource, event in
			self?.lblUsername.text = resource.jsonDict["username"] as? String
		}
		
		bandUpAPI.nearby.loadIfNeeded()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
}
