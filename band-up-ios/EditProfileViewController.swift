//
//  EditProfileViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 28.1.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {
	@IBOutlet weak var btnDone: UIBarButtonItem!
	@IBOutlet weak var btnCancel: UIBarButtonItem!
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	@IBAction func didTapDone(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction func didTapCancel(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
}
