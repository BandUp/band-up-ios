//
//  SettingsViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 18.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.

		let failAlertController = UIAlertController(title: "settings_alert_delete_error_title".localized, message: "settings_alert_delete_error_message".localized, preferredStyle: .alert)

		let okAction = UIAlertAction(title: "search_ok".localized, style: .default, handler: nil)

		failAlertController.addAction(okAction)

		self.present(failAlertController, animated: true, completion: nil)

	}

}
