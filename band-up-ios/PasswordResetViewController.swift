//
//  PasswordResetViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 12.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit

class PasswordResetViewController: UIViewController {
	
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
		super.viewWillAppear(animated)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
}
