//
//  PrivacyViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 24.2.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController {

	// MARK: - UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		title = NSLocalizedString("settings_privacy_policy", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
